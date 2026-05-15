/**
 * Clear - clears the terminal screen via /clear command
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	pi.registerCommand("clear", {
		description: "Clear the terminal screen",
		handler: async (_args, _ctx) => {
			process.stdout.write("\x1b[2J\x1b[H");
		},
	});
}
