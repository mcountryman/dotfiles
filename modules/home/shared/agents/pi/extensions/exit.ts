/**
 * Exit - exits pi via /exit command
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI): void {
	pi.registerCommand("exit", {
		description: "Exit pi",
		handler: async (_args, ctx) => {
			ctx.shutdown();
		},
	});
}
