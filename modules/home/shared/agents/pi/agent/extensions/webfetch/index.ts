/**
 * webfetch - fetch web pages as clean markdown
 *
 * Uses Jina Reader (free, JS rendering) with local turndown fallback.
 * Disk-caches up to 100MB with LRU eviction.
 *
 * Supports segmented reading:
 * - Results are truncated when sent to the model (default: 200 lines).
 * - The model can request a different segment via offset/limit.
 * - Segments of previously fetched pages are served from cache.
 * - User-facing output is collapsed to 10 lines; expand to see the full segment.
 */

import { createHash } from "node:crypto";
import {
	mkdir,
	readdir,
	readFile,
	stat,
	unlink,
	utimes,
	writeFile,
} from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import {
	DEFAULT_MAX_BYTES,
	DEFAULT_MAX_LINES,
	formatSize,
	keyHint,
	truncateHead,
} from "@mariozechner/pi-coding-agent";
import { Text } from "@mariozechner/pi-tui";
import TurndownService from "turndown";
import { Type } from "typebox";

// ── Turndown ────────────────────────────────────────────────────────────────

const td = new TurndownService({
	headingStyle: "atx",
	codeBlockStyle: "fenced",
});

// ── Constants ────────────────────────────────────────────────────────────────

const PRIVATE_HOST_RE =
	/^(127\.|10\.|172\.(1[6-9]|2\d|3[01])\.|192\.168\.|0\.|169\.254\.|localhost$|\[?::1\]?)/iu;

const CACHE_DIR = join(tmpdir(), "pi-webfetch");
const MAX_CACHE = 100 * 1024 * 1024;

/** Default segment size shown to the model on first fetch. */
const DEFAULT_OFFSET = 1;
const DEFAULT_LIMIT = 200;

/** Lines shown in the collapsed TUI view. */
const COLLAPSED_LINES = 10;

// ── URL helpers ──────────────────────────────────────────────────────────────

function normalizeUrl(raw: string): string {
	let url = raw.replace(/^@/u, "");
	if (!/^https?:\/\//iu.test(url)) {
		url = `https://${url}`;
	}
	if (PRIVATE_HOST_RE.test(new URL(url).hostname)) {
		throw new Error(`Private/internal URLs not allowed: ${url}`);
	}
	return url;
}

// ── Fetch backends ───────────────────────────────────────────────────────────

async function jina(url: string, signal?: AbortSignal): Promise<string | null> {
	const r = await fetch(`https://r.jina.ai/${url}`, {
		headers: { Accept: "text/markdown" },
		signal,
	});
	return r.ok ? r.text() : null;
}

async function local(url: string, signal?: AbortSignal): Promise<string> {
	const r = await fetch(url, { signal });
	if (!r.ok) {
		throw new Error(`HTTP ${r.status}: ${r.statusText}`);
	}
	return td.turndown(await r.text());
}

// ── Disk cache ───────────────────────────────────────────────────────────────

function cachePath(url: string): string {
	const hash = createHash("sha256").update(url).digest("hex");
	return join(CACHE_DIR, `${hash}.md`);
}

async function cacheRead(url: string): Promise<string | undefined> {
	try {
		const p = cachePath(url);
		const content = await readFile(p, "utf8");
		await utimes(p, new Date(), new Date());
		return content;
	} catch {
		return undefined;
	}
}

/** Cache the **full** page content (not a truncated slice). */
async function cacheWrite(url: string, content: string): Promise<void> {
	await mkdir(CACHE_DIR, { recursive: true });
	await writeFile(cachePath(url), content, "utf8");
	await evict();
}

async function evict(): Promise<void> {
	const entries: { path: string; mtime: number; size: number }[] = [];

	for (const name of await readdir(CACHE_DIR).catch((): string[] => [])) {
		if (!name.endsWith(".md")) {
			continue;
		}
		const p = join(CACHE_DIR, name);
		const s = await stat(p);
		entries.push({ path: p, mtime: s.mtimeMs, size: s.size });
	}

	entries.sort((a, b) => a.mtime - b.mtime);
	let total = entries.reduce((sum, e) => sum + e.size, 0);

	for (const e of entries) {
		if (total <= MAX_CACHE) {
			break;
		}
		await unlink(e.path).catch(() => {});
		total -= e.size;
	}
}

// ── Details type ────────────────────────────────────────────────────────────

interface WebFetchDetails {
	url: string;
	offset: number;
	segmentLines: number;
	totalLines: number;
	fromCache: boolean;
	/** Full segment text for TUI rendering (not sent to model). */
	content: string;
}

// ── Extension ───────────────────────────────────────────────────────────────

export default function (pi: ExtensionAPI): void {
	pi.registerTool({
		name: "webfetch",
		label: "Web Fetch",
		description:
			"Fetch a web page and convert it to clean markdown. " +
			"Handles JS-rendered pages via Jina Reader. " +
			"Results are truncated to a segment (default: 200 lines); " +
			"use offset and limit to read different segments. " +
			"Previously fetched pages are cached, so re-reading a segment " +
			"does not re-fetch the page.",
		promptSnippet: "Fetch web pages as markdown, with segmented reading",
		promptGuidelines: [
			"Use webfetch when you need to read a web page's content.",
			"If webfetch output shows it is a partial view, call webfetch again with a higher offset to read the next segment.",
			"For a previously fetched URL, use offset/limit to read different segments without re-fetching.",
		],
		parameters: Type.Object({
			url: Type.String({ description: "URL to fetch" }),
			offset: Type.Optional(
				Type.Number({
					description:
						"1-based line offset for the segment to return (default: 1)",
				}),
			),
			limit: Type.Optional(
				Type.Number({
					description: `Maximum lines in the returned segment (default: ${DEFAULT_LIMIT})`,
				}),
			),
		}),

		async execute(_id, params, signal, onUpdate) {
			const url = normalizeUrl(params.url);
			const offset = params.offset ?? DEFAULT_OFFSET;
			const limit = params.limit ?? DEFAULT_LIMIT;

			// ── Resolve full page content (cache → jina → local) ──────────

			let fullContent = await cacheRead(url);
			let fromCache = true;

			if (!fullContent) {
				fromCache = false;

				const signals = [AbortSignal.timeout(30_000)];
				if (signal) {
					signals.push(signal);
				}
				const sig = AbortSignal.any(signals);

				onUpdate?.({
					content: [{ type: "text", text: `Fetching ${url}...` }],
					details: {},
				});

				let md = await jina(url, sig);
				if (!md) {
					md = await local(url, sig);
				}

				// Cache the FULL content so future segment requests hit cache.
				await cacheWrite(url, md);
				fullContent = md;
			}

			// ── Extract requested segment ──────────────────────────────────

			const allLines = fullContent.split("\n");
			const totalLines = allLines.length;

			const startLine = Math.max(1, offset);
			if (startLine > totalLines) {
				throw new Error(
					`Offset ${startLine} is beyond end of page (${totalLines} lines total)`,
				);
			}
			const endLine = Math.min(totalLines, startLine + limit - 1);
			const segmentLines = allLines.slice(startLine - 1, endLine);
			const segmentContent = segmentLines.join("\n");

			// ── Truncate segment if it still exceeds hard limits ───────────

			const truncation = truncateHead(segmentContent, {
				maxLines: DEFAULT_MAX_LINES,
				maxBytes: DEFAULT_MAX_BYTES,
			});

			let text = "";

			// Prepend segment header so model knows the viewport.
			if (startLine > 1 || endLine < totalLines) {
				text += `[Showing lines ${startLine}-${endLine} of ${totalLines}]\n\n`;
			}

			text += truncation.content;

			// Append navigation hints.
			if (truncation.truncated) {
				text += `\n\n[Segment truncated at ${truncation.outputLines} lines (${formatSize(truncation.outputBytes)}).]`;
			}

			if (endLine < totalLines) {
				text += `\n\n[${totalLines - endLine} more lines below. Call webfetch with url="${url}" offset=${endLine + 1} to continue reading.]`;
			}

			if (startLine > 1) {
				text += `\n\n[${startLine - 1} lines above the shown segment. Call webfetch with url="${url}" offset=1 to read from the beginning.]`;
			}

			if (fromCache) {
				text += `\n\n[Served from cache. Page fetched previously.]`;
			}

			return {
				content: [{ type: "text", text }],
				details: {
					url,
					offset: startLine,
					segmentLines: segmentLines.length,
					totalLines,
					fromCache,
					content: segmentContent,
				} as WebFetchDetails,
			};
		},

		// ── TUI rendering ────────────────────────────────────────────────

		renderCall(args, theme, _context) {
			let text = theme.fg("toolTitle", theme.bold("webfetch "));
			text += theme.fg("accent", args.url);
			if (args.offset && args.offset > 1) {
				text += theme.fg("muted", ` line ${args.offset}`);
			}
			if (args.limit && args.limit !== DEFAULT_LIMIT) {
				text += theme.fg("dim", ` limit=${args.limit}`);
			}
			return new Text(text, 0, 0);
		},

		renderResult(result, { expanded }, theme, _context) {
			const details = result.details as WebFetchDetails | undefined;
			if (!details) {
				const [first] = result.content;
				return new Text(first?.type === "text" ? first.text : "", 0, 0);
			}

			// ── Header line ───────────────────────────────────────────
			let header = theme.fg("success", "✓ ");
			if (details.fromCache) {
				header += theme.fg("dim", "(cached) ");
			}
			header += theme.fg("muted", details.url);
			if (details.totalLines > details.segmentLines) {
				header += theme.fg(
					"dim",
					` — lines ${details.offset}-${details.offset + details.segmentLines - 1} of ${details.totalLines}`,
				);
			} else if (details.segmentLines === details.totalLines) {
				header += theme.fg("dim", ` — ${details.totalLines} lines`);
			}

			// ── Content lines ─────────────────────────────────────────
			const contentLines = details.content.split("\n");
			const displayLines = expanded
				? contentLines
				: contentLines.slice(0, COLLAPSED_LINES);

			let text = header;
			for (const line of displayLines) {
				text += `\n${theme.fg("dim", line)}`;
			}

			if (!expanded && contentLines.length > COLLAPSED_LINES) {
				text += `\n${theme.fg("muted", `... ${contentLines.length - COLLAPSED_LINES} more lines (${keyHint("app.tools.expand", "expand")})`)}`;
			}

			return new Text(text, 0, 0);
		},
	});
}
