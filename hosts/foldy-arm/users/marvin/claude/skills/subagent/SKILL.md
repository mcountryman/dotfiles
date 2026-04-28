---
name: subagent
description: Spawn a focused sub-agent from a rough prompt idea. Refines the prompt for precision and token efficiency, selects a cost-appropriate model, and asks for approval before spawning. Use when the user wants to delegate a task to a sub-agent, says things like "spin up an agent to...", "spawn a subagent for...", or invokes /subagent directly.
---

# Subagent Skill

You are executing the `/subagent` skill. Your job is to take a rough prompt idea, refine it into a tight sub-agent prompt, select a cost-appropriate model, and get user approval before spawning.

## Invocation Syntax

```
/subagent [model] [--hard] <rough prompt>
```

- `model` — optional, positional-first. Valid: `haiku`, `sonnet`, `opus`, or full IDs like `claude-sonnet-4-6`, `claude-haiku-4-5`, `claude-opus-4-5`. If omitted, you select the model (see Model Selection below).
- `--hard` — cost is not a concern; maximize quality. Natural-language equivalents in the prompt ("go hard", "don't cut corners", "use your best model", "spare no expense") are treated identically.
- Everything after the optional model/flag tokens is the raw prompt seed.

---

## Step 1 — Parse the invocation

Extract from the user's message:
1. **Model override** — did they specify a model? Normalize shortcuts: `haiku` → `claude-haiku-4-5`, `sonnet` → `claude-sonnet-4-6`, `opus` → `claude-opus-4-5`.
2. **Hard flag** — is `--hard` present, or does natural language signal "no cost concern"?
3. **Raw prompt seed** — everything else.

Do not ask the user anything yet.

---

## Step 2 — Expand the prompt

Produce a thorough, unambiguous sub-agent prompt from the raw seed. Use all available context: current working directory, git status, CLAUDE.md, open files, recent conversation, and anything else visible.

Every expanded prompt must include:
- **Objective** — single clear sentence stating what the sub-agent must accomplish.
- **Context** — relevant facts the sub-agent needs (file paths, repo structure, constraints, prior decisions). Infer from workspace; do not make things up.
- **Expected output** — exact format (file diff, JSON, prose, shell commands, etc.).
- **Scope boundaries** — explicit list of what NOT to do (no unnecessary refactors, no creating new files unless required, no asking follow-up questions, etc.).
- **Token-budget hint** — when output is bounded, add a concise constraint (e.g., "respond in under 300 words", "return only the modified lines, no explanation"). **Omit if `--hard` is set.**

**Efficiency rules (apply unless `--hard` is set):**
- Be precise and complete, but strip filler words, preamble, and redundancy.
- Scope tightly — don't ask the sub-agent to explore the whole codebase if one file suffices.
- Prefer "return only X" over open-ended responses.
- Do not include pleasantries, meta-commentary, or instructions the sub-agent doesn't need.

**When `--hard` is set:** Remove token-budget hints and efficiency constraints. Instruct the sub-agent to be thorough, reason carefully, and not cut corners.

Produce the draft silently — do not show it to the user yet.

---

## Step 3 — Clarifying questions (conditional)

Review the expanded prompt. Ask clarifying questions **only if** critical information is genuinely missing and cannot be inferred — for example:
- The target file or component is ambiguous among multiple plausible candidates.
- Success criteria are undefined and cannot be inferred from context.
- The task contains a contradiction that makes the objective unclear.

If you ask questions, present them as a single numbered list. Do not ask more than three questions. Do not ask back-and-forth — one round only.

If the prompt is actionable without clarification, **skip this step entirely.** Do not ask questions to appear thorough.

---

## Step 4 — Model selection (if not specified by user)

| Tier | Model | Use when |
|------|-------|----------|
| **Low** | `claude-haiku-4-5` | Default for mechanical or well-scoped tasks: file reads, searches, simple transforms, short summaries, anything with bounded and predictable output. |
| **Medium** | `claude-sonnet-4-6` | Moderate reasoning, multi-step logic, non-trivial code generation, or tasks where output quality meaningfully matters. |
| **High** | `claude-opus-4-5` | Only when `--hard` is set, or when the user's language clearly signals a high-stakes or deeply complex task. |

**Default to Haiku unless there is a clear reason to go higher.** When in doubt, Haiku.

If `--hard` is active: always use the most capable available model (currently `claude-opus-4-5`). Note this override in the approval block.

---

## Step 5 — Approval block

Present the following to the user in a compact, clearly formatted block:

```
Sub-agent prompt:
─────────────────────────────────────────────
<expanded prompt>
─────────────────────────────────────────────
Model:      <model ID>  [HARD MODE — cost override active]  ← omit bracket note if --hard not set
Cost tier:  low / medium / high
```

Then on a new line, ask for approval with a frictionless prompt:

```
Spawn sub-agent? [Y/n]
```

- If the user approves (or just hits Enter / says yes / says "go" / says "do it"), proceed to Step 6.
- If the user rejects or asks for changes, revise the prompt or model selection as requested and re-present the approval block.
- Do not spawn without explicit approval.

---

## Step 6 — Spawn

Use the `Agent` tool with:
- `prompt`: the expanded prompt from Step 2 (apply any revisions from Step 5).
- `model`: the selected model ID.

Do not add commentary before or after the Agent tool call. Let the sub-agent's output speak for itself.

---

## Quick reference: cost tiers

| Tier | Model | Signal |
|------|-------|--------|
| low | haiku | Bounded output, mechanical task |
| medium | sonnet | Reasoning or non-trivial codegen |
| high | opus | `--hard` or explicitly high-stakes |
