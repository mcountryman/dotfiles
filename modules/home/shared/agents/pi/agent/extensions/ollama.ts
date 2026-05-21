/**
 * Ollama Provider - auto-discover models from localhost and host.orb.internal
 *
 * Tries to connect to Ollama on both localhost:11434 and
 * host.orb.internal:11434, picks whichever responds, and registers
 * all available models.
 */

import { ModelResponse, Ollama, ShowResponse } from "ollama";
import type {
  ExtensionAPI,
  ProviderModelConfig,
} from "@mariozechner/pi-coding-agent";

const OLLAMA_PORT = 11434;
const CANDIDATES = [
  `http://localhost:${OLLAMA_PORT}`,
  `http://host.orb.internal:${OLLAMA_PORT}`,
];

export default async function (pi: ExtensionAPI) {
  const ollama = await getOllama();
  if (!ollama) {
    return;
  }

  const list = await ollama.list();

  pi.registerProvider("ollama", {
    baseUrl: "http://host.orb.internal:11434/v1",
    api: "openai-completions",
    apiKey: "ollama",
    models: await Promise.all(list.models.map((it) => getModel(ollama, it))),
  });
}

async function getOllama(): Promise<Ollama | null> {
  return new Ollama({
    host: "http://host.orb.internal:11434",
  });
}

async function getModel(ollama: Ollama, model: ModelResponse) {
  const show = await ollama.show({ model: model.name });

  return {
    id: model.name,
    name: getModelName(model.name),
    input: ["text"],
    maxTokens: 8192,
    reasoning: getIsReasoning(model, show),
    contextWindow: getContextWindow(show),
    cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
    compat: {
      supportsDeveloperRole: false,
      supportsReasoningEffort: false,
    },
  } as ProviderModelConfig;
}

function getModelName(id: string): string {
  const parts = id.split(":");
  const base = parts[0] ?? id;
  const basePascal = base.charAt(0).toUpperCase() + base.slice(1);
  const tag = parts[1];

  return tag ? `${basePascal} ${tag} (Ollama)` : `${basePascal} (Ollama)`;
}

function getIsReasoning(model: ModelResponse, show: ShowResponse) {
  // Name patterns that indicate native reasoning/thinking support.
  const REASONING_PATTERNS = [
    /\br1\b/i,
    /think/i,
    /reason/i,
    /gemma4/i,
    /deepseek/i,
    /qwq/i,
  ];

  return (
    show.capabilities.includes("thinking") ||
    REASONING_PATTERNS.some((it) => it.test(model.name))
  );
}

function getContextWindow(show: ShowResponse) {
  for (const [key, value] of Object.entries(show.model_info)) {
    if (!key.endsWith(".context_length")) continue;
    if (typeof value !== "number") continue;

    return value;
  }

  return 32768;
}
