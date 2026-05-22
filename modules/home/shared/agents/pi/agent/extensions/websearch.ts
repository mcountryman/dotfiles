/**
 * websearch - search the web from pi
 *
 * Uses Exa (https://exa.ai) when EXA_API_KEY is set.
 * Falls back to DuckDuckGo HTML search when no key is present.
 */

import { parse as parseHtml } from "node-html-parser";
import process from "node:process";
import {
  getMarkdownTheme,
  keyHint,
  truncateToVisualLines,
  type ExtensionAPI,
} from "@mariozechner/pi-coding-agent";
import { Component, Markdown, Text } from "@mariozechner/pi-tui";
import { Type } from "typebox";
import TurndownService from "turndown";

const USER_AGENT = [
  "Mozilla/5.0 (X11; Linux x86_64)",
  "AppleWebKit/537.36 (KHTML, like Gecko)",
  "Chrome/120.0.0.0 Safari/537.36",
].join(" ");

interface Results {
  query: string;
  results: SearchResult[];
}

export default function (pi: ExtensionAPI): void {
  pi.registerTool({
    name: "websearch",
    label: "Web Search",
    description: "Search the web for current information using DuckDuckGo.",
    promptSnippet: "Search the web for current information",
    promptGuidelines: [
      `Use concise keyword phrases (3–6 words), not natural language questions.`,
      `Drop stopwords, articles, and filler words. Example: instead of "what is the capital of France" use "France capital city".`,
      `Lead with the most distinctive term. "postgres jsonb query nested" not "how to query nested jsonb in postgres".`,
      `For time-sensitive topics, append the year: "react server components 2025".`,
      `For code/technical searches, include version or date if relevant.`,
      `Use site: operator sparingly — DDG's site: is less reliable than Google's.`,
      `For fact verification, include terms like "spec", "docs", "official" to surface authoritative sources.`,
      `DuckDuckGo supports bangs (!w for Wikipedia, !gh for GitHub, etc.) but only use bangs when the user explicitly requests a specific source.`,
    ],
    parameters: Type.Object({
      query: Type.String({ description: "Search query" }),
      numResults: Type.Optional(
        Type.Number({
          description: "Number of results to return (default: 5, max: 10)",
        }),
      ),
    }),

    async execute(_, params, signal) {
      const results = await search(params.query, signal);
      const lines = getMarkdownResultLines(results);

      return {
        content: [{ type: "text", text: lines.join("\n") }],
        details: { results, query: params.query } as Results,
      };
    },

    renderCall(args, theme, _) {
      const title = theme.fg("toolTitle", theme.bold("websearch"));

      if (!args.query) {
        return new Text(title, 0, 0);
      }

      return new Text(`${title} ${theme.fg("accent", args.query)}`, 0, 0);
    },

    renderResult(result, options, theme, _) {
      const lines = getMarkdownResultLines(result.details.results);
      const mdTheme = getMarkdownTheme();

      if (options.expanded || lines.length <= 10) {
        return new Markdown("\n" + lines.join("\n"), 0, 0, mdTheme);
      }

      const expandKey = keyHint("app.tools.expand", "expand");
      const expandHint = theme.fg("muted", `... (${expandKey})`);
      const collapsedLines = getMarkdownCollapsedLines(result.details.results);
      const collapsed = collapsedLines.concat(["", expandHint]).join("\n");

      return new Markdown("\n" + collapsed, 0, 0, mdTheme);
    },
  });
}

const td = new TurndownService({
  headingStyle: "atx",
  codeBlockStyle: "fenced",
});

interface SearchResult {
  title: string;
  url: string;
  snippet: string;
}

async function search(query: string, signal?: AbortSignal) {
  const url = `https://html.duckduckgo.com/html/?q=${encodeURIComponent(query)}`;
  const res = await fetch(url, {
    headers: {
      Accept: "text/html",
      "User-Agent": USER_AGENT,
    },
    signal,
  });

  if (!res.ok) {
    throw new Error(`DuckDuckGo failed: ${res.status} ${res.statusText}`);
  }

  const html = await res.text();
  const root = parseHtml(html);
  const results: SearchResult[] = [];

  for (const el of root.querySelectorAll(".web-result")) {
    const urlEl = el.querySelector(".result__url");
    const titleEl = el.querySelector("a.result__a");
    const snippetEl = el.querySelector(".result__snippet");
    const snippet = snippetEl?.text?.trim() || urlEl?.text?.trim() || "";
    const snippetMd = td.turndown(snippet);

    if (!titleEl) {
      continue;
    }

    // DDG proxies URLs via /l/?uddg=<encoded-url> - extract the real destination
    let url = titleEl.getAttribute("href") ?? "";

    try {
      const urlProxied = `https://duckduckgo.com${url}`;
      const urlParsed = new URL(url.startsWith("/") ? urlProxied : url);
      const uddg = urlParsed.searchParams.get("uddg");

      if (uddg) {
        url = uddg;
      }
    } catch {
      // keep raw href if URL parsing fails
    }

    results.push({
      url: url,
      title: titleEl.text.trim(),
      snippet: snippetMd,
    });
  }

  return results;
}

function getMarkdownResultLines(results: SearchResult[]) {
  if (results.length === 0) {
    return [`No results found (via DuckDuckGo).`];
  }

  let n = 0;
  let lines: string[] = [];
  let blanks = 0;

  for (const { url, title, snippet } of results) {
    n++;
    blanks = 0;

    lines.push(`${n}. **[${formatTitle(title)}](${url})**`);

    for (let line of snippet?.split("\n") ?? []) {
      const trimmed = line.trim();
      if (trimmed.length === 0) {
        blanks++;
      } else {
        blanks = 0;
      }

      // Ignore >1 blank lines
      if (blanks > 1) {
        continue;
      }

      lines.push(`  ${trimmed}`);
    }

    lines.push("");
  }

  return lines;
}

function getMarkdownCollapsedLines(results: SearchResult[]) {
  if (results.length === 0) {
    return [`No results found (via DuckDuckGo).`];
  }

  let n = 0;
  let lines: string[] = [];

  for (const { url, title } of results) {
    n++;

    lines.push(`${n}. [${formatTitle(title)}](${url})`);
  }

  return lines;
}

function formatTitle(title: string) {
  return title.replace(/\s+/g, " ");
}
