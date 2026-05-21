import { ExtensionAPI, ToolCallEvent } from "@mariozechner/pi-coding-agent";

const modes: Mode[] = [
  { name: "default" },
  {
    name: "plan",
    tools: [],
    commands: [],
  },
];

export default async function (pi: ExtensionAPI) {
  let mode = modes[0];

  pi.registerFlag("mode", {
    type: "string",
    default: "default",
    description: "Indicates which agent mode pi is in.",
  });

  pi.registerShortcut("ctrl+7", {
    description: "Cycles agent mode",
    handler(ctx) {
      const next = getNextMode(mode.name);

      ctx.ui.setStatus("mode", next.name);
      mode = next;
    },
  });

  pi.on("tool_call", (event, ctx) => {
    if (!isToolNameAllowed(mode, event.toolName)) {
      return {
        block: true,
        reason: `Tool '${event.toolName}' not allowed in '${mode.name}' mode`,
      };
    }

    if (event.toolName === "bash" && !isCmdAllowed(mode, event.input.command)) {
      return {
        block: true,
        reason: `Bash command '${event.input.command}' not allowed in '${mode.name}' mode`,
      };
    }
  });
}

type Mode = {
  name: string;
  tools?: RegExp[];
  commands?: RegExp[];
};

function getModeByName(name: string): Mode {
  const found = modes.find((it) => it.name === name);
  const fallback = modes[0];

  return found ?? fallback;
}

function getNextMode(name: string): Mode {
  const curr = modes.findIndex((it) => it.name == name);
  const next = (curr + 1) % modes.length;

  return modes[next];
}

function isToolNameAllowed(mode: Mode, toolName: string) {
  return !mode.tools || isAnyRegExpMatch(toolName, mode.tools);
}

function isCmdAllowed(mode: Mode, command: unknown) {
  return !mode.commands || isAnyRegExpMatch(String(command), mode.commands);
}

function isAnyRegExpMatch(test: string, patterns: RegExp[]) {
  for (const pattern of patterns) {
    if (pattern.test(test)) return true;
  }

  return false;
}
