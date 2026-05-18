/**
 * Agent - spawn pi sub-agents
 *
 * Delegates tasks to child pi processes running in json mode.
 */

import { once } from "node:events";
import { spawn } from "node:child_process";
import readline from "node:readline";
import type {
  AgentSessionEvent,
  AgentToolResult,
  AgentToolUpdateCallback,
  ExtensionAPI,
  ExtensionContext,
} from "@mariozechner/pi-coding-agent";
import Type from "typebox";

export default function (pi: ExtensionAPI): void {
  pi.registerTool({
    name: "agent",
    label: "Agent",
    description: "Spawn a sub-agent.",
    promptSnippet: "Spawn a sub-agent with a prompt and wait for it's output",
    promptGuidelines: [
      "Use agent to delegate independent tasks to sub-agents.",
      "Use agent when a user asks to spawn a sub-agent or a background agent",
      "Use the model parameter when the user asks for a specific model",
      "Ensure the prompt paramater contains text to send to the sub-agent",
      "Expect only the response message text from the agent",
      "If the user is asking to delegate commands to a sub-agent ensure" +
        " avoid performing analysis work prior to spawning the sub-agent" +
        " unless specifically requested",
    ],
    parameters: Type.Object({
      prompt: Type.String({ description: "Agent prompt" }),
      model: Type.Optional(Type.String({ description: "Model override" })),
    }),

    async execute(
      _: string,
      params: { prompt: string; model: string },
      signal: AbortSignal | undefined,
      onUpdate: AgentToolUpdateCallback<unknown> | undefined,
      __: ExtensionContext,
    ): Promise<AgentToolResult<unknown>> {
      // Check for cancellation
      if (signal?.aborted) {
        return {
          content: [{ type: "text", text: "Cancelled" }],
          details: {},
        };
      }

      const { prompt, model } = params;
      const tools = pi
        .getAllTools()
        .map((it) => it.name)
        .filter((it) => it !== "agent");

      let output = "";
      let pending = "";
      let pending_kind = "text" as "text" | "thinking";

      function onContentUpdate(kind: "text" | "thinking", text: string) {
        if (kind !== pending_kind) {
          if (pending !== "") {
            pending += "\n\n";
          }

          pending_kind = kind;

          if (kind === "thinking") {
            pending += "> ";
          }
        }

        if (kind === "text") {
          output += text;
        } else if (kind === "thinking") {
          let first = true;

          for (const line of text.split("\n")) {
            if (first) pending += line;
            else pending += `> ${line}`;

            if (first) first = false;
          }
        }

        onUpdate?.({
          details: {},
          content: [{ type: "text", text: pending }],
        });
      }

      for await (const event of spawnSubAgent(prompt, model, tools, signal)) {
        if (event.type === "close") break;

        if (event.type === "message_update") {
          if (event.assistantMessageEvent.type === "text_delta") {
            onContentUpdate("text", event.assistantMessageEvent.delta);
          } else if (event.assistantMessageEvent.type === "thinking_delta") {
            onContentUpdate("thinking", event.assistantMessageEvent.delta);
          }
        }
      }

      // Return result
      return {
        content: [{ type: "text", text: output }], // Sent to LLM
        details: {},
        // Optional: stop after this tool batch when every finalized tool result
        // in the batch also returns terminate: true.
        terminate: true,
      };
    },
  });
}

type SubAgentEvent = AgentSessionEvent | { type: "close"; code: number };

async function* spawnSubAgent(
  prompt: string,
  model?: string,
  tools: string[] = [],
  signal?: AbortSignal,
): AsyncGenerator<SubAgentEvent> {
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
    child.kill();
    lines.close();
  }

  signal?.addEventListener("abort", onAbort);

  try {
    for await (let line of lines) {
      signal?.throwIfAborted();

      yield JSON.parse(line);
    }

    const [code] = await once(child, "close");
    yield { type: "close", code: code ?? 0 };
  } catch (err) {
    if (err.name === "AbortError") {
      yield { type: "close", code: 1 };
    }
  } finally {
    signal?.removeEventListener("abort", onAbort);
    child.kill();
  }
}
