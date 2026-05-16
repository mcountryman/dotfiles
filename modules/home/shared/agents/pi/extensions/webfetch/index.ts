/**
 * webfetch - fetch web pages as clean markdown
 * Uses Jina Reader (free, JS rendering) with local turndown fallback.
 * Disk-caches up to 100MB with LRU eviction.
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
	truncateHead,
} from "@mariozechner/pi-coding-agent";
import TurndownService from "turndown";
import { Type } from "typebox";

const td = new TurndownService({
	headingStyle: "atx",
	codeBlockStyle: "fenced",
});

const PRIVATE_HOST_RE =
	/^(127\.|10\.|172\.(1[6-9]|2\d|3[01])\.|192\.168\.|0\.|169\.254\.|localhost$|\[?::1\]?)/iu;
const CACHE_DIR = join(tmpdir(), "pi-webfetch");
const MAX_CACHE = 100 * 1024 * 1024;

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

export default function (pi: ExtensionAPI): void {
	pi.registerTool({
		name: "webfetch",
		label: "Web Fetch",
		description:
			"Fetch a web page and convert it to clean markdown. " +
			"Handles JS-rendered pages via Jina Reader.",
		promptSnippet: "Fetch web pages as markdown",
		promptGuidelines: [
			"Use webfetch when you need to read a web page's content as markdown.",
		],
		parameters: Type.Object({
			url: Type.String({ description: "URL to fetch" }),
		}),
		async execute(_id, params, signal, onUpdate) {
			const url = normalizeUrl(params.url);
			const hit = await cacheRead(url);

			if (hit) {
				return { content: [{ type: "text", text: hit }], details: {} };
			}

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
			const t = truncateHead(md, {
				maxLines: DEFAULT_MAX_LINES,
				maxBytes: DEFAULT_MAX_BYTES,
			});

			let text = t.content;

			if (t.truncated) {
				text += `\n\n[Truncated: ${t.outputLines}/${t.totalLines} lines]`;
			}

			await cacheWrite(url, text);
			return { content: [{ type: "text", text }], details: {} };
		},
	});
}
