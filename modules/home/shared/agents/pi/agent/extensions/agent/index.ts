/**
 * Agent - spawn background pi sub-agents
 *
 * Delegates tasks to child pi processes running in json mode.
 * Tracks activity per agent and renders a collapsible TUI widget.
 * Results are delivered to the parent via sendUserMessage on completion.
 */

import { spawn } from "node:child_process";
import { randomUUID } from "node:crypto";
import { existsSync } from "node:fs";
import process from "node:process";
import type { Message } from "@mariozechner/pi-ai";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Type } from "typebox";

const COLLAPSED = 10;
const POLL_MS = 500;

interface Agent {
	id: string;
	task: string;
	proc: ReturnType<typeof spawn>;
	lines: string[];
	done: boolean;
	result?: string;
	error?: string;
}

type WidgetCtx = {
	ui: ExtensionAPI extends {
		registerTool: (...args: infer _A) => infer _R;
	} & infer T
		? T & { ui: { setWidget: (name: string, widget: unknown) => void } }
		: never;
};

function getPiCmd(): { cmd: string; prefix: string[] } {
	const [, script] = process.argv;
	if (script && !script.startsWith("/$bunfs/root/") && existsSync(script)) {
		return { cmd: process.execPath, prefix: [script] };
	}
	return { cmd: "pi", prefix: [] };
}

function finalText(msgs: Message[]): string {
	for (let i = msgs.length - 1; i >= 0; i--) {
		if (msgs[i].role === "assistant") {
			for (const p of msgs[i].content) {
				if (p.type === "text") {
					return p.text;
				}
			}
		}
	}
	return "";
}

export default function (pi: ExtensionAPI): void {
	const agents = new Map<string, Agent>();
	let expanded = false;
	let pollTimer: ReturnType<typeof setInterval> | undefined;
	let widgetCtx: WidgetCtx | undefined;

	function renderWidget(_width: number): string[] {
		const entries = [...agents.values()];
		if (entries.length === 0) {
			return [];
		}
		const out: string[] = [];
		for (const a of entries) {
			const icon = a.done ? (a.error ? "✗" : "✓") : "⏳";
			out.push(`${icon} ${a.id.slice(0, 8)} ${a.task.slice(0, 40)}`);
			const shown = expanded ? a.lines : a.lines.slice(-COLLAPSED);
			out.push(...shown);
		}
		return out;
	}

	function startPoll(ctx: WidgetCtx): void {
		if (pollTimer) {
			return;
		}
		widgetCtx = ctx;
		pollTimer = setInterval(() => {
			if (!widgetCtx) {
				return;
			}
			widgetCtx.ui.setWidget("agent", {
				render: renderWidget,
				invalidate(): void {},
			});
		}, POLL_MS);
	}

	function stopPoll(): void {
		if (pollTimer) {
			clearInterval(pollTimer);
			pollTimer = undefined;
		}
	}

	function spawnAgent(
		id: string,
		task: string,
		model: string | undefined,
		systemPrompt: string | undefined,
		cwd: string,
		_ctx: WidgetCtx,
	): void {
		const { cmd, prefix } = getPiCmd();
		const allTools = pi.getAllTools();
		const toolNames = allTools
			.map((t: (typeof allTools)[number]) => t.name)
			.filter((n: string) => n !== "agent");
		const argv = [
			...prefix,
			"--mode",
			"json",
			"-p",
			"--no-session",
			"--tools",
			toolNames.join(","),
		];
		if (model) {
			argv.push("--model", model);
		}
		if (systemPrompt) {
			argv.push("--append-system-prompt", systemPrompt);
		}
		argv.push(task);

		const proc = spawn(cmd, argv, {
			cwd,
			shell: false,
			stdio: ["ignore", "pipe", "pipe"],
		});
		const agent: Agent = { id, task, proc, lines: [], done: false };
		agents.set(id, agent);

		let buf = "";
		const msgs: Message[] = [];
		proc.stdout.on("data", (d: Buffer) => {
			buf += d.toString();
			const parts = buf.split("\n");
			buf = parts.pop() || "";
			for (const line of parts) {
				if (!line.trim()) {
					continue;
				}
				try {
					const ev = JSON.parse(line);
					if (ev.type === "message_end" && ev.message) {
						msgs.push(ev.message);
					}
					if (ev.type === "tool_result_end" && ev.message) {
						msgs.push(ev.message);
					}
					if (
						ev.type === "message_update" &&
						ev.assistantMessageEvent?.type === "text_delta"
					) {
						agent.lines.push(ev.assistantMessageEvent.delta);
					}
					if (ev.type === "tool_execution_start") {
						agent.lines.push(`→ ${ev.toolName}`);
					}
				} catch {
					/* skip malformed */
				}
			}
		});

		proc.stderr.on("data", (d: Buffer) => {
			agent.lines.push(d.toString().trim());
		});

		proc.on("close", (code: number) => {
			agent.done = true;
			agent.result = finalText(msgs);
			if (code !== 0) {
				agent.error = `exit ${code}`;
			}
			const summary = agent.error
				? `Agent ${id.slice(0, 8)} failed: ${agent.error}`
				: `Agent ${id.slice(0, 8)} completed:\n${agent.result}`;
			pi.sendUserMessage(summary);
			if ([...agents.values()].every((a) => a.done)) {
				stopPoll();
			}
		});
	}

	pi.registerShortcut("ctrl+o", {
		description: "Toggle agent widget expand/collapse",
		handler: async (_ctx) => {
			expanded = !expanded;
		},
	});

	pi.registerTool({
		name: "agent",
		label: "Agent",
		description:
			"Spawn background pi sub-agents. Actions: start, status, stop.",
		promptSnippet: "Spawn background agents for parallel work",
		promptGuidelines: [
			"Use agent to delegate independent tasks to sub-agents.",
			"agent is always async — start returns an ID immediately.",
			"Poll status to check progress. Results arrive via user messages.",
		],
		parameters: Type.Object({
			action: Type.Union(
				[Type.Literal("start"), Type.Literal("status"), Type.Literal("stop")],
				{ description: "Action to perform" },
			),
			task: Type.Optional(
				Type.String({ description: "Task description (start)" }),
			),
			model: Type.Optional(
				Type.String({ description: "Model override (start)" }),
			),
			system_prompt: Type.Optional(
				Type.String({
					description: "Additional system prompt (start)",
				}),
			),
			id: Type.Optional(Type.String({ description: "Agent ID (status/stop)" })),
		}),

		async execute(
			_tid: string,
			params: Record<string, unknown>,
			_sig: unknown,
			_onUp: unknown,
			ctx: Record<string, unknown>,
		) {
			const { action, task, model, system_prompt, id } = params as {
				action: string;
				task?: string;
				model?: string;
				system_prompt?: string;
				id?: string;
			};

			if (action === "start") {
				if (!task) {
					return {
						content: [{ type: "text", text: "Missing task" }],
						isError: true,
					};
				}
				const agentId = randomUUID();
				spawnAgent(
					agentId,
					task,
					model,
					system_prompt,
					ctx.cwd as string,
					ctx as WidgetCtx,
				);
				startPoll(ctx as WidgetCtx);
				return {
					content: [
						{ type: "text", text: `Agent ${agentId.slice(0, 8)} started` },
					],
					details: { id: agentId },
				};
			}

			if (action === "status") {
				if (id) {
					const a = agents.get(id);
					if (!a) {
						return {
							content: [{ type: "text", text: "Unknown agent" }],
							isError: true,
						};
					}
					return {
						content: [
							{
								type: "text",
								text: a.done
									? `Done: ${a.result?.slice(0, 200)}`
									: `Running (${a.lines.length} lines)`,
							},
						],
						details: {
							id: a.id,
							done: a.done,
							error: a.error,
							lines: a.lines.length,
						},
					};
				}
				const all = [...agents.values()].map((a) => ({
					id: a.id.slice(0, 8),
					done: a.done,
					error: a.error,
					lines: a.lines.length,
				}));
				return {
					content: [{ type: "text", text: JSON.stringify(all) }],
					details: { agents: all },
				};
			}

			if (action === "stop") {
				if (!id) {
					return {
						content: [{ type: "text", text: "Missing id" }],
						isError: true,
					};
				}
				const a = agents.get(id);
				if (!a) {
					return {
						content: [{ type: "text", text: "Unknown agent" }],
						isError: true,
					};
				}
				a.proc.kill("SIGTERM");
				a.done = true;
				a.error = "stopped";
				return {
					content: [{ type: "text", text: `Agent ${id.slice(0, 8)} stopped` }],
				};
			}

			return {
				content: [{ type: "text", text: `Unknown action: ${action}` }],
				isError: true,
			};
		},
	});

	pi.on("session_shutdown", async () => {
		for (const a of agents.values()) {
			if (!a.done) {
				a.proc.kill("SIGTERM");
			}
		}
		stopPoll();
		if (widgetCtx) {
			widgetCtx.ui.setWidget("agent", undefined);
		}
	});
}
