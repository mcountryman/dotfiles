/**
 * Footer - renders pi's bottom status bar
 *
 * Reads PI_NONO_PROFILE env var set by the wrapper script
 * and displays the variant label right-aligned on the pwd line,
 * directly above the model name on the stats line.
 */

import process from "node:process";
import type { AssistantMessage } from "@mariozechner/pi-ai";
import type {
  ExtensionAPI,
  ExtensionContext,
  ReadonlyFooterDataProvider,
  Theme,
} from "@mariozechner/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@mariozechner/pi-tui";

const VARIANT_MAP: Record<string, string> = {
  "pi-readonly": "readonly",
  "pi-plan": "plan",
  pi: "default",
};

interface FooterCtx {
  ctx: ExtensionContext;
  footerData: ReadonlyFooterDataProvider;
  variant: string;
  thinkingLevel: string | undefined;
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
        invalidate(): void {},
        render(width: number): string[] {
          const footer: FooterCtx = { ctx, footerData, variant, thinkingLevel };
          const dim = (s: string) => theme.fg("dim", s);

          const line1 = joinLine(
            width,
            renderTopLeft(footer, width, theme),
            renderTopRight(footer, width, theme),
            dim,
          );

          const line2 = joinLine(
            width,
            renderBottomLeft(footer, width, theme),
            renderBottomRight(footer, width, theme),
            dim,
          );

          const line3 = renderExtensionLine(footer, width, theme);

          return [line1, line2, line3].filter(Boolean);
        },
      };
    });
  });
}

function renderTopLeft(footer: FooterCtx, _: number, theme: Theme): string {
  const { ctx, footerData } = footer;

  let pwd = ctx.sessionManager.getCwd();
  const home = process.env.HOME || process.env.USERPROFILE;
  const branch = footerData.getGitBranch();
  const sessionName = ctx.sessionManager.getSessionName();

  if (home && pwd.startsWith(home)) {
    pwd = `~${pwd.slice(home.length)}`;
  }
  if (branch) {
    pwd = `${pwd} (${branch})`;
  }
  if (sessionName) {
    pwd = `${pwd} • ${sessionName}`;
  }

  return theme.fg("dim", pwd);
}

function renderTopRight(footer: FooterCtx, _: number, theme: Theme): string {
  return theme.fg("borderAccent", footer.variant);
}

function renderBottomLeft({ ctx }: FooterCtx, _: number, theme: Theme): string {
  let totalInput = 0;
  let totalOutput = 0;
  let totalCost = 0;
  const usage = ctx.getContextUsage();
  const contextWindow = usage?.contextWindow ?? ctx.model?.contextWindow ?? 0;
  const contextPercentValue = usage?.percent ?? 0;
  const contextPercent =
    usage?.percent != null ? contextPercentValue.toFixed(1) : "?";
  const parts: string[] = [];
  const autoIndicator = " (auto)";
  const contextDisplay =
    contextPercent === "?"
      ? `?/${formatTokens(contextWindow)}${autoIndicator}`
      : `${contextPercent}%/${formatTokens(contextWindow)}${autoIndicator}`;

  for (const e of ctx.sessionManager.getEntries()) {
    if (e.type === "message" && e.message.role === "assistant") {
      const m = e.message as AssistantMessage;
      totalInput += m.usage.input;
      totalOutput += m.usage.output;
      totalCost += m.usage.cost.total;
    }
  }
  if (totalInput) {
    parts.push(`↑${formatTokens(totalInput)}`);
  }
  if (totalOutput) {
    parts.push(`↓${formatTokens(totalOutput)}`);
  }
  if (totalCost) {
    parts.push(`$${totalCost.toFixed(3)}`);
  }
  if (contextPercentValue > 90) {
    parts.push(theme.fg("error", contextDisplay));
  } else if (contextPercentValue > 70) {
    parts.push(theme.fg("warning", contextDisplay));
  } else {
    parts.push(contextDisplay);
  }

  return theme.fg("dim", parts.join(" "));
}

function renderBottomRight(footer: FooterCtx, _: number, theme: Theme): string {
  const { ctx, footerData, thinkingLevel } = footer;
  const level = thinkingLevel || "off";
  const modelName = ctx.model?.id || "no-model";

  let rightSide = modelName;

  if (ctx.model?.reasoning) {
    rightSide =
      level === "off"
        ? `${modelName} • thinking off`
        : `${modelName} • ${level}`;
  }

  if (footerData.getAvailableProviderCount() > 1 && ctx.model) {
    rightSide = `(${ctx.model.provider}) ${rightSide}`;
  }

  return theme.fg("dim", rightSide);
}

function renderExtensionLine(
  { footerData }: FooterCtx,
  width: number,
  theme: Theme,
): string {
  const statuses = footerData.getExtensionStatuses();
  if (statuses.size === 0) {
    return "";
  }

  const sorted = Array.from(statuses.entries())
    .sort(([a], [b]) => a.localeCompare(b))
    .map(([, text]) => text);

  return truncateToWidth(sorted.join(" "), width, theme.fg("dim", "..."));
}

/** Pad between left and right text to fill `width`, truncating if needed. */
function joinLine(
  width: number,
  left: string,
  right: string,
  dim: (s: string) => string,
): string {
  const leftWidth = visibleWidth(left);
  const rightWidth = visibleWidth(right);

  if (leftWidth + 2 + rightWidth <= width) {
    const padding = " ".repeat(width - leftWidth - rightWidth);
    return left + padding + right;
  }

  const availableForRight = width - leftWidth - 2;
  if (availableForRight > 0) {
    const truncatedRight = truncateToWidth(right, availableForRight, "");
    const truncatedRightWidth = visibleWidth(truncatedRight);
    const padding = " ".repeat(
      Math.max(0, width - leftWidth - truncatedRightWidth),
    );
    return left + padding + truncatedRight;
  }

  return truncateToWidth(left, width, dim("..."));
}

function formatTokens(n: number): string {
  return n < 1000 ? `${n}` : `${(n / 1000).toFixed(1)}k`;
}
