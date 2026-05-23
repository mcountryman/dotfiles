/**
 * Agent - spawn pi sub-agents
 *
 * Delegates tasks to child pi processes running in json mode.
 */

import { spawn } from "node:child_process";
import { readdir, readFile } from "node:fs/promises";
import path from "node:path";
import readline from "node:readline/promises";
import type {
	TextContent,
	ThinkingContent,
	ToolCall,
} from "@mariozechner/pi-ai";
import type {
	AgentToolResult,
	ExtensionAPI,
	Theme,
} from "@mariozechner/pi-coding-agent";
import {
	type AgentSessionEvent,
	getAgentDir,
	parseFrontmatter,
	truncateToVisualLines,
} from "@mariozechner/pi-coding-agent";
import { type Component, Text } from "@mariozechner/pi-tui";
import { Type } from "typebox";

export default async function (pi: ExtensionAPI) {
	const dir = path.join(getAgentDir(), "agents");
	const agents = await getAgentConfs(dir);

	pi.registerTool({
		name: "agent",
		label: "Agent",
		description: "Spawn a sub-agent.",
		promptSnippet: "Spawn a sub-agent with a prompt and wait for it's output",
		promptGuidelines: [
			"A tool to spawn a sub-agent in pi to avoid using up too much context",
			...agents
				.filter(agent => agent.promptGuideline)
				.map(agent => String(agent.promptGuideline)),
		],
		parameters: Type.Object({
			prompt: Type.String({ description: "Agent prompt" }),
			agent: Type.Optional(
				Type.String({
					default: "default",
					description: "The name of the agent to run",
				}),
			),
		}),

		async execute(
			_toolCallId,
			{ prompt, agent = "default" },
			signal,
			onUpdate,
			_ctx,
		): Promise<AgentToolResult<Details>> {
			const conf = agents.find(candidate => candidate.name === agent);
			if (!conf) {
				throw new Error(`Agent with the name '${agent}' doesn't exist`);
			}

			let calls: Call[] = [];
			let text = "";
			let thinking = "";
			let events: AgentSessionEvent[] = [];

			for await (const event of run(prompt, conf, signal)) {
				if (event.type === "close") {
					break;
				}

				if (event.type === "message_update") {
					if (event.assistantMessageEvent.type === "thinking_start") {
						thinking = "";
					}

					if (event.assistantMessageEvent.type === "thinking_delta") {
						thinking += event.assistantMessageEvent.delta;
					}
				}

				if (event.type === "message_end") {
					if (event.message.role === "assistant") {
						text += getTextContent(event.message.content);
					}
				}

				events.push(event);
				calls.push(...getToolCalls(events));

				// Event stream hammers memory if we don't limit it.  Maybe an object
				// pool would make sense here.  GC takes a while to recover.
				events = events.slice(-128);
				calls = calls.slice(-50);

				onUpdate?.({
					content: [],
					details: { calls, text, thinking },
				});
			}

			return {
				content: [{ type: "text", text }],
				details: { calls, text, thinking },
			};
		},

		renderCall({ agent: agentName }, theme, _) {
			const conf = agents.find(entry => entry.name === agentName) ?? agents[0];

			const title = theme.fg("toolTitle", theme.bold("agent"));
			const label =
				conf.name !== "default" ? theme.fg("muted", `(${conf.name})`) : "";

			return new Text(`${title} ${label}`, 0, 0);
		},

		renderResult({ details }, _options, theme, ctx) {
			if (ctx.isError) {
				throw new Error();
			}

			return {
				invalidate() {},
				render(width) {
					const lines: string[] = [];

					const calls = formatCompactToolCalls(details.calls, theme);
					const callsTrunc = truncateToVisualLines(calls.join("\n"), 10, width);
					const callLines = callsTrunc.visualLines;

					lines.push(...callLines);

					const label = details.thinking.trim() || details.text.trim() || "";
					const labelTrunc = truncateToVisualLines(label, 3, width);
					const labelLines = labelTrunc.visualLines.map(line =>
						theme.fg("thinkingText", line),
					);

					lines.push(...labelLines);

					return lines;
				},
			} as Component;
		},
	});
}

interface Details {
	text: string;
	calls: Call[];
	thinking: string;
}

async function* run(prompt: string, conf: Conf, signal?: AbortSignal) {
	const argv = [
		// output json
		...["--mode", "json"],
		// non-interactive
		"--print",
		// don't record history
		"--no-session",

		...(conf.model ? ["--model", conf.model] : []),
		...(conf.tools ? ["--tools", conf.tools.join(",")] : []),
		...(conf.prompt ? ["--append-system-prompt", conf.prompt] : []),

		prompt,
	];

	const child = spawn("pi-raw", argv, { stdio: ["ignore", "pipe", "pipe"] });
	const lines = readline.createInterface({
		signal,
		input: child.stdout,
		terminal: false,
		crlfDelay: Infinity,
	});

	let stderr = "";

	child.stderr?.setEncoding("utf8");
	child.stderr?.on("data", chunk => (stderr += chunk));

	function onAbort() {
		child.kill("SIGKILL");
		lines.close();
	}

	signal?.addEventListener("abort", onAbort);

	try {
		for await (const line of lines) {
			yield JSON.parse(line) as AgentSessionEvent;
		}

		const code = await new Promise<number | null>(resolve => {
			child.once("exit", exitCode => resolve(exitCode));
			child.once("close", exitCode => resolve(exitCode));
		});

		if (code !== 0 && typeof code === "number") {
			throw new Error(stderr.trim() || `Exit code ${code}`);
		} else if (code === null) {
			throw new Error("Cancelled");
		}

		yield { type: "close" } as const;
	} catch (err) {
		throw new Error(`Failed (${err})`);
	} finally {
		signal?.removeEventListener("abort", onAbort);
		child.kill();
		lines.close();
	}
}

interface Conf {
	name: string;
	model?: string;
	tools?: string[];
	prompt?: string;
	promptGuideline?: string;
}

async function getAgentConfs(dir: string) {
	const configs = [{ name: "default" } as Conf];

	let entries: string[];
	try {
		entries = await readdir(dir);
	} catch {
		return configs;
	}

	for (const entry of entries) {
		if (!entry.endsWith(".md")) {
			continue;
		}

		const name = path.basename(entry, ".md");
		const file = path.join(dir, entry);
		const markdown = await readFile(file, "utf8");
		const { body, frontmatter: conf } = parseFrontmatter(markdown);

		configs.push({
			name: conf.name ? String(conf.name) : name,
			model: conf.model ? String(conf.model) : undefined,
			tools: conf.tools ? String(conf.tools).split(",") : undefined,
			prompt: body,
			promptGuideline: conf.promptGuideline
				? String(conf.promptGuideline)
				: undefined,
		});
	}

	return configs;
}

function getTextContent(chunks: (TextContent | ThinkingContent | ToolCall)[]) {
	return chunks
		.filter(chunk => chunk.type === "text")
		.map(chunk => chunk.text)
		.join("");
}

function formatCompactToolCalls(calls: Call[], theme: Theme) {
	const lines: string[] = [];

	for (const call of calls) {
		const argsFmt = formatToolArgs(call.args);
		const argsDisplay = argsFmt?.slice(0, 80);
		const args = argsDisplay && theme.fg("muted", argsDisplay);
		const name = theme.fg("toolTitle", call.name);
		const symbol = theme.fg(call.status, call.status !== "warning" ? "●" : "◌");

		if (!args) {
			lines.push(`${symbol} ${name}`);
		} else {
			lines.push(`${symbol} ${name} ${args}`);
		}
	}

	return lines;
}

function formatToolArgs(args: unknown): string | null {
	if (args === null || args === undefined) {
		return null;
	}

	switch (typeof args) {
		case "string":
			return args;
		case "number":
		case "bigint":
			return args.toLocaleString();
		case "boolean":
			return String(args);
		case "object":
			if (Array.isArray(args)) {
				return args.map(formatToolArgs).filter(Boolean).join(", ");
			} else {
				return Object.entries(args)
					.map(([k, v]) => [k, formatToolArgs(v)])
					.filter(([_, v]) => v !== null)
					.map(([k, v]) => `${k}=${v}`)
					.join(", ");
			}
		default:
			return null;
	}
}

type Call = CallOk | CallErr | CallPending;
type CallOk = { name: string; args: unknown; status: "success" };
type CallErr = { name: string; args: unknown; status: "error" };
type CallPending = { name: string; args: unknown; status: "warning" };

function* getToolCalls(events: AgentSessionEvent[]) {
	for (let i = 0; i < events.length; i++) {
		const event = events[i];
		if (event.type !== "tool_execution_start") {
			continue;
		}

		const { toolCallId, toolName: name } = event;
		const last = [...events]
			.reverse()
			.filter(entry => "toolCallId" in entry)
			.filter(entry => entry.toolCallId === toolCallId)
			.find(entry => entry.type !== "tool_execution_start");

		const args =
			last?.type === "tool_execution_update" ? last.args : event.args;
		const status =
			last?.type === "tool_execution_end"
				? last.isError
					? "error"
					: "success"
				: "warning";

		yield { name, args, status } as Call;
	}
}
