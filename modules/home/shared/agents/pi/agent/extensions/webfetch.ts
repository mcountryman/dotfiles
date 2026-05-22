/**
 * webfetch - fetch web pages as clean markdown
 *
 * Uses Jina Reader API (free tier, JS rendering) via eu-r-beta.jina.ai.
 * In-memory cache up to 100MB with LRU eviction (1h TTL, max 100MB).
 *
 * Supports segmented reading:
 * - Results are truncated to 20KB by default (MAX_BYTES) when sent to the model.
 * - The model can request a different segment via skip/take parameters.
 * - Segments of previously fetched pages are served from cache.
 */

import { LRUCache } from "lru-cache";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { formatSize } from "@mariozechner/pi-coding-agent";
import { Text, Component } from "@mariozechner/pi-tui";
import { Type } from "typebox";

const JINA_URL = "https://eu-r-beta.jina.ai/";
// const JINA_TOKEN = null as string | null;

const MAX_BYTES = 1024 * 20; // 20KB;

const cache = new LRUCache<string, ResultOk>({
  ttl: 1000 * 60 * 60, // 1h
  maxSize: 1024 * 1024 * 100, // 100MB

  sizeCalculation(result) {
    return Buffer.byteLength(result.markdown, "utf8");
  },
});

export default function (pi: ExtensionAPI): void {
  pi.registerTool({
    name: "webfetch",
    label: "Web Fetch",
    description: "Fetch a web page and convert it to clean markdown",
    promptSnippet: "Fetch web pages as markdown, with segmented reading",
    promptGuidelines: [
      "Pages are large — start with default skip/take to preview, then refine",
      "Use skip to jump past content you've already seen; use take to limit what's returned",
      "Same URL re-fetched = served from cache (no re-download, no extra cost)",
      `The maximum value for the take parameter is ${MAX_BYTES}`,
      `Scan incrementally: skip=0 → skip=${MAX_BYTES} → skip=${MAX_BYTES * 2} to walk through long pages`,
    ],
    parameters: Type.Object({
      url: Type.String({ description: "URL to fetch" }),
      skip: Type.Optional(
        Type.Number({
          default: 0,
          minimum: 0,
          description: "The number of bytes to skip in the fetched result",
        }),
      ),
      take: Type.Optional(
        Type.Number({
          default: MAX_BYTES,
          maximum: MAX_BYTES,
          description: `The number of bytes to return from the fetched result`,
        }),
      ),
    }),

    async execute(_, { url, skip, take }, signal) {
      skip = Math.max(skip ?? 0);
      take = Math.min(take ?? MAX_BYTES, MAX_BYTES);

      const result = await getMarkdownCached(url, signal);
      if (!result.ok) {
        throw new Error(`Failed (${result.status})`);
      }

      const text = getAgentContent(result.markdown, skip, take);

      return {
        content: [{ type: "text", text }],
        details: { result },
      };
    },

    renderCall({ url, skip, take }, theme, _context) {
      const range =
        (skip && ` [${skip}..${skip + (take ?? MAX_BYTES)}]`) ||
        (take && ` [..${take}]`) ||
        "";

      const title = theme.fg("toolTitle", theme.bold("webfetch"));
      if (!url) {
        return new Text(title, 0, 0);
      }

      const rangeArg = theme.fg("muted", range);
      const urlArg = theme.fg("accent", url);

      return new Text(`${title} ${urlArg}${rangeArg}`, 0, 0);
    },

    renderResult({ details }, _, theme, __): Component {
      const { status, markdown, cached } = details.result;
      const size = formatSize(Buffer.byteLength(markdown, "utf8"));
      const suffix = cached ? theme.fg("muted", "cached") : "";

      return new Text(
        theme.fg("toolOutput", `Received ${size} (${status}) ${suffix}`),
        1,
        0,
      );
    },
  });
}

type Result = ResultOk | ResultErr;
type ResultOk = { ok: true; status: string; markdown: string; cached: boolean };
type ResultErr = { ok: false; status: string };

async function getMarkdownCached(url: string, signal?: AbortSignal) {
  const entry = cache.get(url);
  if (entry) {
    return entry;
  }

  try {
    const result = await getMarkdown(url, signal);
    if (result.ok) {
      cache.set(url, { ...result, cached: true });
    }

    return result;
  } catch (err) {
    return { ok: false, status: err.message } as ResultErr;
  }
}

async function getMarkdown(url: string, signal?: AbortSignal): Promise<Result> {
  const res = await fetch(`${JINA_URL}/${url}`, {
    signal,
    headers: {
      // Authorization: "Bearer ..",
      "X-Robots-Txt": "JinaReader", // Don't be mean
      "X-Return-Format": "markdown",
      // "X-Retain-Images": "none",
      // "X-With-Iframe": "true",
      "X-Cache-Tolerance": "300", // Allow 5m of cache
    },
  });

  const status = `${res.status} ${res.statusText}`;

  if (!res.ok) {
    return { ok: false, status };
  }

  const markdown = await res.text();

  return { ok: true, status, markdown, cached: false };
}

function getAgentContent(markdown: string, skip: number, take: number) {
  const text = markdown.substring(skip, skip + take);

  const remaining = markdown.length - text.length;
  const skipNext = skip + text.length;

  return [
    text,
    `--- ${remaining} bytes remaining · skip=${skipNext} to continue ---`,
  ].join("\n");
}
