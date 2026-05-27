/**
 * Notify - sends desktop notifications when pi finishes processing
 *
 * Listens for agent_end events and writes JSON-line payloads
 * to a well-known file ($HOME/.pi/notify) for a systemd
 * path unit to pick up and forward to the macOS Notification Center.
 *
 * Designed with a Notifier interface so other backends can be
 * added later (e.g. direct osascript on macOS, notify-send on Linux).
 */

import { exec } from "node:child_process";
import { appendFile } from "node:fs/promises";
import { homedir } from "node:os";
import { join } from "node:path";
import process from "node:process";
import { promisify } from "node:util";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

const execAsync = promisify(exec);

const NOTIFY_FILE = join(process.env.HOME || homedir(), ".pi", "notify");

export default function (pi: ExtensionAPI) {
	if (process.env.PI_AGENT_DEPTH) {
		return;
	}

	let prompt = "";

	pi.on("before_agent_start", (event, _) => {
		prompt = event.prompt.trim();
	});

	pi.on("agent_end", async (_, ctx) => {
		const name = ctx.sessionManager.getSessionName();
		const title = !name ? `pi.dev` : `pi.dev - ${name}`;

		await notify({
			title,
			subtitle: "",
			message: prompt,
		});
	});
}

interface NotificationPayload {
	title: string;
	subtitle: string;
	message: string;
}

async function notify(payload: NotificationPayload) {
	const line = `${JSON.stringify(payload)}\n`;
	const visible = await isVisible();

	try {
		if (visible) {
			return;
		}

		await appendFile(NOTIFY_FILE, line, { encoding: "utf8" });
	} catch {
		// Silently fail — notifications are best-effort
	}
}

async function isVisible() {
	const paneId = process.env.TMUX_PANE;
	if (!paneId) {
		return false;
	}

	const fmt = "#{session_attached} #{window_active} #{pane_active}";
	const { stdout } = await execAsync(
		`tmux display-message -t ${paneId} -p '${fmt}'`,
	);

	const [attached, windowActive, paneActive] = stdout.trim().split(" ");
	return attached === "1" && windowActive === "1" && paneActive === "1";
}
