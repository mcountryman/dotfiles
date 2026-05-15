/**
 * Clear - clears the terminal screen and resets conversation context to session start
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	pi.registerCommand("clear", {
		description: "Clear the terminal screen and reset conversation to session start",
		handler: async (_args, ctx) => {
			const branch = ctx.sessionManager.getBranch();
			const root = branch[0];
			if (root) {
				await ctx.navigateTree(root.id);
			}
			process.stdout.write("\x1b[2J\x1b[H");
		},
	});
}
