/**
 * Variant - shows which pi binary variant is running in the footer
 *
 * Reads PI_NONO_PROFILE env var set by the wrapper script
 * and displays the variant label right-aligned on the pwd line,
 * directly above the model name on the stats line.
 */

import process from "node:process";

import type { AssistantMessage } from "@mariozechner/pi-ai";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@mariozechner/pi-tui";

const VARIANT_MAP: Record<string, string> = {
	"pi-readonly": "readonly",
	"pi-plan": "plan",
	pi: "default",
};

function formatTokens(n: number): string {
	return n < 1000 ? `${n}` : `${(n / 1000).toFixed(1)}k`;
}

export default function (pi: ExtensionAPI): void {
	const profile = process.env.PI_NONO_PROFILE || "pi";
	const variant = VARIANT_MAP[profile] ?? profile;

	let thinkingLevel: string | undefined;

	pi.on("thinking_level_select", async (event) => {
		thinkingLevel = event.level;
	});

	pi.on("session_start", async (_event, ctx) => {
		ctx.ui.setFooter((tui, theme, footerData) => {
			const unsubBranch = footerData.onBranchChange(() => tui.requestRender());

			return {
				dispose: unsubBranch,
				invalidate() {},
				render(width: number): string[] {
					// Line 1: pwd + git branch (left) | variant label (right, aligned above model name)
					let pwd = ctx.sessionManager.getCwd();
					const home = process.env.HOME || process.env.USERPROFILE;
					if (home && pwd.startsWith(home)) {
						pwd = `~${pwd.slice(home.length)}`;
					}
					const branch = footerData.getGitBranch();
					if (branch) {
						pwd = `${pwd} (${branch})`;
					}
					const sessionName = ctx.sessionManager.getSessionName();
					if (sessionName) {
						pwd = `${pwd} • ${sessionName}`;
					}

					const variantLabel = theme.fg("borderAccent", variant);
					const pwdStyled = theme.fg("dim", pwd);
					const pwdWidth = visibleWidth(pwdStyled);
					const variantWidth = visibleWidth(variantLabel);

					let line1: string;
					if (pwdWidth + 2 + variantWidth <= width) {
						const padding = " ".repeat(width - pwdWidth - variantWidth);
						line1 = pwdStyled + padding + variantLabel;
					} else {
						line1 = truncateToWidth(pwdStyled, width, theme.fg("dim", "..."));
					}

					// Line 2: token stats (left) + model name (right)
					let totalInput = 0;
					let totalOutput = 0;
					let totalCost = 0;
					for (const e of ctx.sessionManager.getEntries()) {
						if (e.type === "message" && e.message.role === "assistant") {
							const m = e.message as AssistantMessage;
							totalInput += m.usage.input;
							totalOutput += m.usage.output;
							totalCost += m.usage.cost.total;
						}
					}

					const contextUsage = ctx.getContextUsage();
					const contextWindow = contextUsage?.contextWindow ?? ctx.model?.contextWindow ?? 0;
					const contextPercentValue = contextUsage?.percent ?? 0;
					const contextPercent = contextUsage?.percent != null ? contextPercentValue.toFixed(1) : "?";

					const leftParts: string[] = [];
					if (totalInput) leftParts.push(`↑${formatTokens(totalInput)}`);
					if (totalOutput) leftParts.push(`↓${formatTokens(totalOutput)}`);
					if (totalCost) leftParts.push(`$${totalCost.toFixed(3)}`);

					const autoIndicator = " (auto)";
					const contextDisplay =
						contextPercent === "?"
							? `?/${formatTokens(contextWindow)}${autoIndicator}`
							: `${contextPercent}%/${formatTokens(contextWindow)}${autoIndicator}`;

					if (contextPercentValue > 90) {
						leftParts.push(theme.fg("error", contextDisplay));
					} else if (contextPercentValue > 70) {
						leftParts.push(theme.fg("warning", contextDisplay));
					} else {
						leftParts.push(contextDisplay);
					}

					const left = theme.fg("dim", leftParts.join(" "));

					const modelName = ctx.model?.id || "no-model";
					let rightSide = modelName;
					if (ctx.model?.reasoning) {
						const level = thinkingLevel || "off";
						rightSide = level === "off" ? `${modelName} • thinking off` : `${modelName} • ${level}`;
					}
					if (footerData.getAvailableProviderCount() > 1 && ctx.model) {
						rightSide = `(${ctx.model.provider}) ${rightSide}`;
					}

					const rightStyled = theme.fg("dim", rightSide);

					const leftWidth = visibleWidth(left);
					const rightWidth = visibleWidth(rightStyled);

					let line2: string;
					if (leftWidth + 2 + rightWidth <= width) {
						const padding = " ".repeat(width - leftWidth - rightWidth);
						line2 = left + padding + rightStyled;
					} else {
						const availableForRight = width - leftWidth - 2;
						if (availableForRight > 0) {
							const truncatedRight = truncateToWidth(rightStyled, availableForRight, "");
							const truncatedRightWidth = visibleWidth(truncatedRight);
							const padding = " ".repeat(Math.max(0, width - leftWidth - truncatedRightWidth));
							line2 = left + padding + truncatedRight;
						} else {
							line2 = truncateToWidth(left, width, theme.fg("dim", "..."));
						}
					}

					// Other extension statuses
					const extensionStatuses = footerData.getExtensionStatuses();
					const lines = [line1, line2];
					if (extensionStatuses.size > 0) {
						const sortedStatuses = Array.from(extensionStatuses.entries())
							.sort(([a], [b]) => a.localeCompare(b))
							.map(([, text]) => text);
						lines.push(truncateToWidth(sortedStatuses.join(" "), width, theme.fg("dim", "...")));
					}

					return lines;
				},
			};
		});
	});
}
