/**
 * LSP Diagnostics for pi — curated language server diagnostics without context bloat.
 * Servers spawn on-demand and live for the session. Configure servers in SERVERS.
 */
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Type } from "typebox";
import { spawn, type ChildProcess } from "node:child_process";
import { readFile } from "node:fs/promises";
import { resolve, extname } from "node:path";
import { createMessageConnection, type MessageConnection } from "vscode-jsonrpc";

// ext → [command, args, languageId]
const SERVERS: Record<string, [string, string[], string]> = {
  ".nix":  ["nixd",   [],    "nix"],
  ".rs":   ["rust-analyzer", [], "rust"],
  ".ts":   ["typescript-language-server", ["--stdio"], "typescript"],
  ".tsx":  ["typescript-language-server", ["--stdio"], "typescriptreact"],
  ".js":   ["typescript-language-server", ["--stdio"], "javascript"],
  ".toml": ["taplo",  ["lsp", "stdio"], "toml"],
  ".md":   ["marksman", [], "markdown"],
};

const SEV = ["", "error", "warning", "info", "hint"];
const pool = new Map<string, { conn: MessageConnection; proc: ChildProcess }>();
const pending = new Map<string, ((d: any[]) => void)[]>();
const openDocs = new Set<string>(); // track URIs we've already opened

async function ensureServer(ext: string, rootPath: string) {
  const cached = pool.get(ext);
  if (cached && !cached.proc.exitCode) return cached;
  pool.delete(ext); // clean up dead entry
  const [cmd, args] = SERVERS[ext];
  const proc = spawn(cmd, args, { stdio: ["pipe", "pipe", "pipe"] });
  proc.on("error", () => pool.delete(ext));
  const conn = createMessageConnection(proc.stdout, proc.stdin, { error() {}, warn() {}, info() {}, log() {} });
  conn.onNotification("textDocument/publishDiagnostics", (p: any) => {
    const cbs = pending.get(p.uri);
    if (cbs) { for (const cb of cbs) cb(p.diagnostics); pending.set(p.uri, []); }
  });
  conn.listen();
  const rootUri = `file://${rootPath}`;
  await conn.sendRequest("initialize", {
    processId: process.pid, rootUri, capabilities: {
      textDocument: { synchronization: { dynamicRegistration: false } },
    }, workspaceFolders: [{ uri: rootUri, name: "root" }]
  });
  conn.sendNotification("initialized", {});
  const srv = { conn, proc };
  pool.set(ext, srv);
  return srv;
}

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "lsp_diagnostics",
    label: "LSP Diagnostics",
    description: "Get language server diagnostics (errors, warnings) for a source file. Curated output capped at 50 items.",
    promptSnippet: "Check source files for type errors and lint warnings",
    promptGuidelines: ["Use lsp_diagnostics to catch errors that reading source alone might miss."],
    parameters: Type.Object({
      file_path: Type.String({ description: "Path to source file (relative to cwd or absolute)" }),
    }),
    async execute(_id, params, _sig, _upd, ctx) {
      const abs = resolve(ctx.cwd, params.file_path);
      const ext = extname(abs);
      if (!SERVERS[ext]) return { content: [{ type: "text", text: `No LSP configured for ${ext} files` }], details: {} };

      try {
        const uri = `file://${abs}`;
        const srv = await ensureServer(ext, ctx.cwd);

        // Register listener BEFORE didOpen to avoid race
        let resolved = false;
        const diagPromise = new Promise<any[]>((resolve) => {
          const arr = pending.get(uri) ?? [];
          arr.push(resolve);
          pending.set(uri, arr);
        });

        const timeoutPromise = new Promise<any[]>((resolve) => {
          setTimeout(() => {
            if (resolved) return;
            // Remove our listener from pending
            const arr = pending.get(uri);
            if (arr) pending.set(uri, arr.filter(cb => cb !== resolve));
            resolve([]);
          }, 10000);
        });

        // Block until diagnostics arrive or timeout
        const text = await readFile(abs, "utf-8");
        if (openDocs.has(uri)) {
          // Re-open already-tracked doc: send full change
          srv.conn.sendNotification("textDocument/didChange", {
            textDocument: { uri, version: Date.now() },
            contentChanges: [{ text }],
          });
        } else {
          srv.conn.sendNotification("textDocument/didOpen", {
            textDocument: { uri, languageId: SERVERS[ext][2], version: Date.now(), text },
          });
          openDocs.add(uri);
        }

        const diags: any[] = await Promise.race([diagPromise, timeoutPromise]).finally(() => { resolved = true; });

        const lines = diags.slice(0, 50).map((d: any) =>
          `${params.file_path}:${(d.range?.start?.line ?? 0) + 1}:${(d.range?.start?.character ?? 0) + 1} ${SEV[d.severity] ?? "?"}: ${d.message?.split("\n")[0]}`
        );
        if (diags.length > 50) lines.push(`... +${diags.length - 50} more`);
        return { content: [{ type: "text", text: lines.length ? lines.join("\n") : "No diagnostics." }], details: {} };
      } catch (e: any) {
        return { content: [{ type: "text", text: `LSP error: ${e.message}` }], details: { error: e.message } };
      }
    },
  });

  pi.on("session_shutdown", () => {
    for (const { conn, proc } of pool.values()) { conn.dispose(); proc.kill(); }
    pool.clear();
  });
}
