/**
 * Agent - spawn pi sub-agents
 *
 * Delegates tasks to child pi processes running in json mode.
 */

import { once } from "node:events";
import { spawn } from "node:child_process";
import readline from "node:readline";
import {
  Component,
  Container,
  DefaultTextStyle,
  Markdown,
  Spacer,
  Text,
} from "@mariozechner/pi-tui";
import {
  getMarkdownTheme,
  keyHint,
  Theme,
  ThemeColor,
  type AgentSessionEvent,
  type AgentToolResult,
  type AgentToolUpdateCallback,
  type ExtensionAPI,
  type ExtensionContext,
} from "@mariozechner/pi-coding-agent";
import Type from "typebox";
import { AssistantMessageEvent, Usage } from "@mariozechner/pi-ai";
import { keyText } from "@mariozechner/pi-coding-agent";

const MAX_COLLAPSED_LOG_LINES = 10;

export default function (pi: ExtensionAPI): void {
  let usage = newUsage();

  interface Details {
    chunks: AgentChunks;
  }

  pi.registerTool({
    name: "agent",
    label: "Agent",
    description: "Spawn a sub-agent.",
    promptSnippet: "Spawn a sub-agent with a prompt and wait for it's output",
    promptGuidelines: [
      "Use agent to delegate independent tasks to sub-agents.",
      "Use agent when a user asks to spawn a sub-agent or a background agent",
      "Ensure the prompt paramater contains text to send to the sub-agent",
      "Expect only the response message text from the agent",
      "If the user is asking to delegate commands to a sub-agent ensure" +
        " avoid performing analysis work prior to spawning the sub-agent" +
        " unless specifically requested",
    ],
    parameters: Type.Object({
      prompt: Type.String({ description: "Agent prompt" }),
    }),

    async execute(
      _: string,
      params: { prompt: string },
      signal: AbortSignal | undefined,
      onUpdate: AgentToolUpdateCallback<Details> | undefined,
      ctx: ExtensionContext,
    ): Promise<AgentToolResult<Details>> {
      const chunks = new AgentChunks();

      // Check for cancellation
      if (signal?.aborted) {
        return {
          content: [{ type: "text", text: "Cancelled" }],
          details: { chunks },
        };
      }

      const { prompt } = params;
      const tools = pi
        .getAllTools()
        .map((it) => it.name)
        .filter((it) => it !== "agent");

      let text = "";

      for await (const event of subagent(
        prompt,
        ctx.model?.name,
        tools,
        signal,
      )) {
        chunks.push(event);
        onUpdate?.({
          content: [{ type: "text", text }],
          details: { chunks },
        });

        // User requests cancellation
        if (signal?.aborted) break;
        // Sub-agent died with a non-zero exit code
        if (event.type === "close" && event.code !== 0)
          throw new Error(`Non-zero exit code: ${event.code}`);
        // Sub-agent died successfully
        if (event.type === "close") break;
        // Sub-agent said something important
        if (event.type === "message_update") {
          if (event.assistantMessageEvent.type === "text_delta") {
            text += event.assistantMessageEvent.delta;
          }
        }

        if (event.type === "message_end") {
          if (event.message.role === "assistant") {
            usage = sumUsageCost(usage, event.message.usage);
          }
        }
      }

      // Return result
      return {
        content: [{ type: "text", text }],
        details: { chunks },
        terminate: true,
      };
    },

    renderResult(result, options, theme, _) {
      if (!options.isPartial) {
        return new AgentChunksLog(
          result.details.chunks,
          theme,
          options.expanded,
        );
      }

      return new AgentChunksLog(result.details.chunks, theme, options.expanded);
    },
  });

  pi.on("message_end", (event, _) => {
    if (event.message.role !== "assistant") {
      return event;
    }

    event.message.usage = sumUsageCost(usage, event.message.usage);
    // reset to avoid double adds
    usage = newUsage();

    return event;
  });
}

type AgentEvent = AgentSessionEvent | { type: "close"; code: number };

async function* subagent(
  prompt: string,
  model?: string,
  tools: string[] = [],
  signal?: AbortSignal,
): AsyncGenerator<AgentEvent> {
  signal?.throwIfAborted();

  const argv = [
    // output json
    ...["--mode", "json"],
    // non-interactive
    "--print",
    // don't record history
    "--no-session",

    ...(model ? ["--model", model] : []),
    ...(tools.length > 0 ? ["--tools", tools.join(",")] : []),

    prompt,
  ];

  const child = spawn("pi-raw", argv, { stdio: ["ignore", "pipe", "inherit"] });
  const lines = readline.createInterface({
    input: child.stdout,
    terminal: false,
    crlfDelay: Infinity,
  });

  function onAbort() {
    child.kill("SIGKILL");
    lines.close();
  }

  signal?.addEventListener("abort", onAbort);

  try {
    for await (let line of lines) {
      yield JSON.parse(line);
    }

    const [code] = await once(child, "close");
    yield { type: "close", code: code ?? 0 };
  } catch (err) {
    if (err.name === "AbortError") {
      yield { type: "close", code: 1 };
    } else {
      throw err;
    }
  } finally {
    signal?.removeEventListener("abort", onAbort);
    child.kill();
    lines.close();
  }
}

type AgentChunk = [AgentChunkKind, string];
type AgentChunkKind = "text" | "thinking" | "tool";

class AgentChunks {
  constructor(private readonly chunks: AgentChunk[] = []) {}

  get(): AgentChunk[] {
    return this.chunks;
  }

  push(event: AgentEvent) {
    function fmt(args: unknown): string {
      if (args === null) return "";
      if (args === undefined) return "";
      if (Array.isArray(args)) {
        return args.map(fmt).join(", ");
      }

      if (typeof args === "object") {
        const entries = Object.entries(args);
        if (entries.length === 0) return "";
        if (entries.length === 1) return fmt(entries[0][1]);

        return entries.map(([k, v]) => `${fmt(k)}=${fmt(v)}`).join(", ");
      }

      return `${args}`;
    }

    const last = this.chunks.length - 1;
    let next: [AgentChunkKind, string] | null = null;

    // Identify the chunk type & content
    if (event.type === "message_update") {
      if (event.assistantMessageEvent.type === "text_delta") {
        next = ["text", event.assistantMessageEvent.delta];
      } else if (event.assistantMessageEvent.type === "thinking_delta") {
        next = ["thinking", event.assistantMessageEvent.delta];
      } else if (event.assistantMessageEvent.type === "toolcall_start") {
        if (event.message.role === "assistant") {
          for (const chunk of event.message.content) {
            if (chunk.type === "toolCall") {
              const name = chunk.name;
              const args = fmt(chunk.arguments);

              next = ["tool", `**${name}** ${args}`];
            }
          }
        }
      }
    }

    // No chunk found, ignore
    if (!next) {
      return;
    }

    // Update the most recent chunk if it's the same kind
    if (last >= 0 && next[0] === this.chunks[last][0]) {
      this.chunks[last][1] += next[1];
      this.chunks[last][1] = this.chunks[last][1]
        .replace("\\t", "\t")
        .replace("\\r", "\r")
        .replace("\\n", "\n");

      return;
    }

    // Append the new chunk
    this.chunks.push(next);
  }
}

class AgentChunksLog implements Component {
  constructor(
    private readonly chunks: AgentChunks,
    private readonly theme: Theme,
    private readonly expanded: boolean,
  ) {}

  render(width: number): string[] {
    const theme = this.theme;
    const container = new Container();

    container.addChild(new Spacer(1));

    for (const chunk of this.chunks.get()) {
      container.addChild(this._getChunkComponent(chunk));
    }

    container.addChild(new Spacer(1));

    if (this.expanded) {
      return container.render(width);
    }

    const lines: string[] = [];

    for (const chunk of container.render(width)) {
      for (const line of chunk.split("\n")) {
        lines.push(line);
      }
    }

    if (lines.length <= MAX_COLLAPSED_LOG_LINES) {
      return lines;
    }

    const truncated = lines.splice(-MAX_COLLAPSED_LOG_LINES);
    const remaining = lines.length - MAX_COLLAPSED_LOG_LINES;

    const expandHintHead = theme.fg("muted", `(${remaining} more lines, `);
    const expandHintMid = keyHint("app.tools.expand", "to expand");
    const expandHintTail = theme.fg("muted", `)`);
    const expandHint = [expandHintHead, expandHintMid, expandHintTail].join("");

    return [
      "", // padding line
      ...truncated,
      "", // padding line
      expandHint,
    ];
  }

  invalidate() {}

  _getChunkComponent([kind, text]: AgentChunk): Component {
    function getMarkdownTextStyle(
      theme: Theme,
      color: ThemeColor,
    ): DefaultTextStyle {
      return {
        color(text) {
          return theme.fg(color, text);
        },
      };
    }

    const mdTheme = getMarkdownTheme();
    const mdThinkingStyle = getMarkdownTextStyle(this.theme, "thinkingText");
    const mdToolStyle: DefaultTextStyle = {
      color: (text) => this.theme.fg("toolTitle", text),
      bgColor: (text) => this.theme.bg("toolPendingBg", text),
    };

    switch (kind) {
      case "text":
        return new Markdown(text, 0, 0, mdTheme);
      case "thinking":
        return new Markdown(text, 0, 0, mdTheme, mdThinkingStyle);
      case "tool": {
        const container = new Container();

        container.addChild(new Spacer(1));
        container.addChild(new Markdown(text, 1, 1, mdTheme, mdToolStyle));
        container.addChild(new Spacer(1));

        return container;
      }
    }
  }
}

function newUsage(): Usage {
  return {
    input: 0,
    output: 0,
    cacheRead: 0,
    cacheWrite: 0,
    totalTokens: 0,
    cost: {
      input: 0,
      output: 0,
      cacheRead: 0,
      cacheWrite: 0,
      total: 0,
    },
  };
}

function sumUsageCost(a: Usage, b: Usage): Usage {
  return {
    input: a.input,
    output: a.output,
    cacheRead: a.cacheRead,
    cacheWrite: a.cacheWrite,
    totalTokens: a.totalTokens,
    cost: {
      input: a.cost.input + b.cost.input,
      output: a.cost.output + b.cost.output,
      cacheRead: a.cost.cacheRead + b.cost.cacheRead,
      cacheWrite: a.cost.cacheWrite + b.cost.cacheWrite,
      total: a.cost.total + b.cost.total,
    },
  };
}
