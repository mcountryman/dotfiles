/**
 * websearch - search the web from pi
 *
 * Uses Exa (https://exa.ai) when EXA_API_KEY is set.
 * Falls back to DuckDuckGo HTML search when no key is present.
 */

import process from "node:process";

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Type } from "typebox";

interface SearchResult {
	title: string;
	url: string;
	snippet: string;
}

async function searchWithExa(
	query: string,
	numResults: number,
	apiKey: string,
): Promise<SearchResult[]> {
	const { default: Exa } = await import("exa-js");
	const exa = new Exa(apiKey);

	const response = await exa.searchAndContents(query, {
		numResults,
		useAutoprompt: true,
		text: { maxCharacters: 800 },
	});

	return response.results.map((r) => ({
		title: r.title ?? "(no title)",
		url: r.url,
		snippet: r.text ?? "",
	}));
}

async function searchWithDDG(
	query: string,
	numResults: number,
	signal?: AbortSignal,
): Promise<SearchResult[]> {
	const { parse } = await import("node-html-parser");

	const url = `https://html.duckduckgo.com/html/?q=${encodeURIComponent(query)}`;
	const response = await fetch(url, {
		headers: {
			"User-Agent":
				"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
			Accept: "text/html",
		},
		signal,
	});

	if (!response.ok) {
		throw new Error(
			`DuckDuckGo search failed: ${response.status} ${response.statusText}`,
		);
	}

	const html = await response.text();
	const root = parse(html);
	const results: SearchResult[] = [];
	for (const result of root.querySelectorAll(".result")) {
		if (results.length >= numResults) {
			break;
		}

		// Try both DDG HTML selectors (their markup can vary slightly)
		const titleEl =
			result.querySelector("a.result__a") ??
			result.querySelector(".result__title a");
		const snippetEl = result.querySelector(".result__snippet");
		const urlEl = result.querySelector(".result__url");

		if (!titleEl) {
			continue;
		}

		// DDG proxies URLs via /l/?uddg=<encoded-url> - extract the real destination
		let resultUrl = titleEl.getAttribute("href") ?? "";
		try {
			const parsed = new URL(
				resultUrl.startsWith("/")
					? `https://duckduckgo.com${resultUrl}`
					: resultUrl,
			);
			const uddg = parsed.searchParams.get("uddg");

			if (uddg) {
				resultUrl = uddg;
			}
		} catch {
			// keep raw href if URL parsing fails
		}

		results.push({
			title: titleEl.text.trim(),
			url: resultUrl,
			snippet: snippetEl?.text.trim() ?? urlEl?.text.trim() ?? "",
		});
	}

	return results;
}

function formatResults(results: SearchResult[], backend: string): string {
	if (results.length === 0) {
		return `No results found (via ${backend}).`;
	}

	const lines = results.map((r, i) => {
		const parts = [`${i + 1}. **${r.title}**`, `   ${r.url}`];

		if (r.snippet) {
			parts.push(`   ${r.snippet}`);
		}

		return parts.join("\n");
	});

	return `Search results via ${backend}:\n\n${lines.join("\n\n")}`;
}

export default function (pi: ExtensionAPI): void {
	pi.registerTool({
		name: "websearch",
		label: "Web Search",
		description:
			"Search the web for current information. Uses Exa when EXA_API_KEY is set, otherwise DuckDuckGo.",
		promptSnippet: "Search the web for current information",
		parameters: Type.Object({
			query: Type.String({ description: "Search query" }),
			numResults: Type.Optional(
				Type.Number({
					description: "Number of results to return (default: 5, max: 10)",
				}),
			),
		}),
		async execute(_toolCallId, params, signal) {
			const numResults = Math.min(params.numResults ?? 5, 10);
			const apiKey = process.env.EXA_API_KEY;

			let results: SearchResult[];
			let backend: string;

			if (apiKey) {
				results = await searchWithExa(params.query, numResults, apiKey);
				backend = "Exa";
			} else {
				results = await searchWithDDG(params.query, numResults, signal);
				backend = "DuckDuckGo (free)";
			}

			return {
				content: [{ type: "text", text: formatResults(results, backend) }],
				details: { results, backend, query: params.query },
			};
		},
	});
}
