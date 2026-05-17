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

import { appendFile } from "node:fs/promises";
import { homedir } from "node:os";
import { join } from "node:path";
import process from "node:process";

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

interface NotificationPayload {
	title: string;
	subtitle: string;
	message: string;
}

interface Notifier {
	send(payload: NotificationPayload): Promise<void>;
}

/**
 * File notifier — appends JSON lines to a well-known path.
 * A systemd path unit watches the file and forwards to macOS.
 */
class FileNotifier implements Notifier {
	private readonly filePath: string;

	constructor(filePath: string) {
		this.filePath = filePath;
	}

	async send(payload: NotificationPayload): Promise<void> {
		const line = `${JSON.stringify(payload)}\n`;
		try {
			await appendFile(this.filePath, line, { encoding: "utf8" });
		} catch {
			// Silently fail — notifications are best-effort
		}
	}
}

/**
 * Detect which notifier to use based on the current platform.
 * Currently only supports the file-based bridge for NixOS/OrbStack.
 * Extend this function to add macOS direct osascript support, etc.
 */
function createNotifier(): Notifier {
	const notifyFile = join(process.env.HOME || homedir(), ".pi", "notify");
	return new FileNotifier(notifyFile);
}

export default function (pi: ExtensionAPI): void {
	const notifier = createNotifier();

	pi.on("agent_end", async (_event, _ctx) => {
		await notifier.send({
			title: "Pi",
			subtitle: "Task completed",
			message: "Agent has finished processing",
		});
	});
}
