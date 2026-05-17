---
name: plan
description: >
  Creates implementation plans for multi-step tasks (1-10 commits). Explores
  codebase, grills user on requirements one question at a time, then writes a
  precise, TDD-based plan with complete code and verification steps. Use when
  user says "plan this", "create a plan", "let's plan", or invokes /plan.
---

# Planning Skill

**Announce at start of Phase 1:** "I'm using the planning skill to create the
implementation plan."

## Constraints

- This skill ONLY writes files to `$PWD/.agents/plans/`. It never writes to any
  other directory.
- Plans are NEVER committed. If `.agents/plans/` is not in `.gitignore`, stop
  and warn the user. Do not modify `.gitignore` yourself — the user must resolve
  it. Do not proceed until resolved.
- This skill produces plans only. It does not execute them.
- Scope: 1-10 commits. If exploration reveals the task is <1 commit, suggest
  doing it directly instead. If the task spans multiple independent subsystems,
  suggest splitting into separate plans before proceeding.
- If a plan file with the same name already exists, warn the user before
  overwriting.

## Workflow

Phase 1: Explore → Phase 2: Grill → Phase 3: Plan

### Phase 1: Explore

**First action:** Announce "I'm using the planning skill to create the
implementation plan."

Then build context before asking any questions:

1. **Project conventions** — check for `AGENTS.md`, `CLAUDE.md`, `.pi/AGENT.md`,
   `.agents/AGENT.md` in the project root and ancestors. Read them.
2. **Quality tools discovery** — identify lint, format, and quality-checking tools
   applicable to the files being changed. Discovery order:
   a. **Explicit tools** — check `AGENTS.md` (or equivalent) for any explicitly
      documented quality commands (e.g., "run `nix flake check`", "run `biome check`").
      These are authoritative and must be included.
   b. **Configuration-based tools** — scan the project for tool config files
      (e.g., `biome.json`, `.eslintrc*`, `.prettierrc*`, `pyproject.toml` with
      `[tool.ruff]`, `flake.nix` formatter/check definitions, `Makefile` lint
      targets). If a config exists, include the corresponding tool.
   c. **Style exemplars** — identify 2-3 existing human-written source files in the
      same language and same type as the files being changed. These serve as
      style references for conformance checking.
3. **Code exploration** — read relevant source files, understand current
   structure, identify touchpoints for the requested change.
4. **Web search** (optional) — if the task involves unfamiliar libraries, APIs,
   or external services, search for documentation. Skip if not needed.

Write exploration findings to the plan file's `Context` section immediately.
Write discovered quality tools to the plan file's `Quality Tools` section.
This ensures context survives session interruption.

### Phase 2: Grill

Ask the user questions ONE AT A TIME using the `ask` tool. Never batch. The
goal is shared understanding — both agent and user should converge on exactly
what needs to be built.

**Before asking a question, always check:** Can this be answered by reading
code, documentation, configuration, or project conventions? If yes, read the
relevant files and infer the answer instead of asking. Only ask the user when
the answer requires their intent, preference, or a decision that cannot be
derived from the codebase.

**Never repeat questions.** Track all previous questions and answers in the
plan file's `Decisions` section. Before formulating a new question, review what
has already been asked and answered. If a question touches on previously
covered ground, restate the known answer instead of re-asking.

Question types to use (adapted from requirements elicitation):

- **Exploratory**: "What should happen when [scenario]?"
- **Clarifying**: "You mentioned [X] — does that mean [Y] or [Z]?"
- **Confirming**: "To confirm: [restate understanding]. Correct?"
- **Probing**: "What if [edge case]? How should that be handled?"
- **Prioritizing**: "Between [A] and [B], which matters more?"

**Using the `ask` tool:** Call the `ask` tool with a single question and at
least one option. Use the `ask` tool's `questions` parameter — an array with one
question object containing a `question` string and an `options` array. For
open-ended questions, include a `"Other / custom answer"` option so the user can
type freely.

After EVERY answer:

1. Record the decision in the plan file's `Decisions` section (just the
   decision, not the full Q&A).
2. Update any affected sections of the plan (file structure, tasks, etc.) to
   reflect the new decision.

**Termination:** The grilling phase ends when you can name every file, every
function signature, and every test case without guessing. Typically this takes
5-10 questions. If unsure whether understanding is complete, ask one more
question.

**Enforcement:** Each grilling turn must call the `ask` tool with exactly one
question. No preamble, no "Great, thanks!" — just the question in the `ask`
tool call. If you must acknowledge the answer, keep it to one sentence in the
response after the `ask` tool result, then call `ask` again with the next
question.

### Phase 3: Plan

Write the full implementation plan to `$PWD/.agents/plans/<plan-name>.md`.

Then self-review:

1. Read the plan-reviewer-prompt.md template (resolve relative to this skill's
   directory).
2. Run the checklist against the plan.
3. Fix any issues found.
4. Write the review output to `$PWD/.agents/plans/<plan-name>-review.md`.
5. Present a summary of issues found and fixes applied to the user.
6. Delete the review file after presenting.
7. Ask for sign-off.

If the user requests revisions, make them and repeat the self-review before
re-presenting.

## Plan File Format

Save to: `$PWD/.agents/plans/<plan-name>.md`

`<plan-name>`: kebab-case derived from the task summary (e.g.,
`add-user-authentication.md`).

If a file with the same name already exists, warn the user before overwriting.

### Template

````markdown
# [Feature Name] Implementation Plan

**Goal:** [One sentence: what this builds and why it matters]

**Architecture:** [2-3 sentences: approach and key decisions]

**Tech Stack:** [Key technologies/libraries]

---

## Context

[Exploration findings: current state, relevant files, project conventions,
external docs consulted. Written during Phase 1.]

## Quality Tools

| File Pattern | Tool | Command | Source |
| ------------ | ---- | ------- | ------ |
| `*.nix` | nixfmt | `nix fmt --check` | AGENTS.md / flake.nix formatter |
| `*.nix` | nix flake check | `nix flake check` | AGENTS.md |
| `modules/home/shared/agents/pi/agent/extensions/**/*.ts` | biome | `biome check` | AGENTS.md / biome.json |
| ... | ... | ... | ... |

**Style Exemplars:**

| Language/Type | Reference File(s) |
| ------------- | ----------------- |
| Nix module | `path/to/existing/module.nix` |
| TypeScript extension | `path/to/existing/extension.ts` |
| ... | ... | ... |

## Decisions

-
-

## Surprises & Discoveries

- [Observation]: [Evidence or context]

## File Structure

| Action | Path                                      | Responsibility         |
| ------ | ----------------------------------------- | ---------------------- |
| Create | `exact/path/to/new-file.ext`              | [What this file does]  |
| Modify | `exact/path/to/existing-file.ext:L10-L25` | [What changes and why] |

Line-range format: `filename.ext:L<start>-L<end>`

## Tasks

### Task 1: [Component Name]

**Depends on:** [Task N] or None

**Files:**

- Create: `exact/path/to/new-file.ext`
- Modify: `exact/path/to/existing-file.ext:L10-L25` (if necessary)

- [ ] **Step 1: Write the failing test**

  ```language
  [test code]
  ```

- [ ] **Step 2: Run test to verify it fails**

  Run: `exact test command` Expected: FAIL with [specific error]

- [ ] **Step 3: Write minimal implementation**

  ```language
  [implementation code]
  ```

- [ ] **Step 4: Run test to verify it passes**

  Run: `exact test command` Expected: PASS

- [ ] **Step 5: Quality verification**

  Run ALL applicable quality tools for the changed files. Every tool must pass.

  | Tool | Command | Expected |
  | ---- | ------- | -------- |
  | [tool] | `[command]` | PASS (no output / exit 0) |
  | [tool] | `[command]` | PASS (no output / exit 0) |

  **Style conformance check:** Compare new/modified code against the style
  exemplars listed in the `Quality Tools` section. Verify:
  - Naming conventions match (variable, function, file naming patterns)
  - Code structure patterns match (module layout, import ordering, export style)
  - Idiomatic patterns are followed (language-specific constructs, error handling style)

  If deviations are found, fix them before proceeding. Deviations are only
  acceptable if the new code's purpose genuinely requires a different pattern.

- [ ] **Step 6: Commit**

  ```bash
  git add [files]
  git commit -m "feat: [conventional commit message]"
  ```

### Task 2: ...

[Same structure repeated for each task]
````

For tasks that do not produce executable code (directories, config, docs, etc.),
replace the test/implement cycle with a single verification step:

````markdown
- [ ] **Step 1: [Action description]**

  [commands or content]

- [ ] **Step 2: Quality verification**

  Run ALL applicable quality tools for the changed files. Every tool must pass.

  | Tool | Command | Expected |
  | ---- | ------- | -------- |
  | [tool] | `[command]` | PASS (no output / exit 0) |
  | [tool] | `[command]` | PASS (no output / exit 0) |

  **Style conformance check:** Compare new/modified code against the style
  exemplars listed in the `Quality Tools` section. Verify naming, structure,
  and idiomatic patterns match. If deviations are found, fix them before
  proceeding.

- [ ] **Step 3: Commit**

  ```bash
  git add [files]
  git commit -m "chore: [message]"
  ```
````

Timestamps (`YYYY-MM-DD HH:MM`) are left blank during planning. They are filled
by the execution agent as each step is completed.

## Rules

1. **No placeholders.** Every code step contains the actual code. Never write:
   TBD, TODO, "implement later", "add appropriate error handling", "write tests
   for the above" without actual test code, "similar to Task N" without
   repeating the code.
2. **TDD for executable code.** Tasks producing code follow: write failing test
   → verify fail → implement → verify pass → quality check → commit. Config/doc/structure tasks
   use quality check + verify step instead.
3. **Exact file paths always.** Never write "the relevant file" or "in the
   appropriate module."
4. **Complete code in every step.** If a step changes code, show the code.
5. **Verification in every task.** Exact commands with expected output.
6. **Quality verification in every code task.** Every task that creates or modifies source files must include a quality verification step. All applicable tools must pass. Style conformance against exemplars must be checked.
7. **One `ask` tool call per turn.** Never batch questions during grilling.
   Always use the `ask` tool to present the question to the user.
8. **Persist after every answer.** Write decisions and updates to the plan file
   after each grilling answer.
9. **Scope check.** If the task spans multiple independent subsystems, suggest
   splitting before proceeding. If <1 commit, suggest doing it directly.
10. **DRY, YAGNI.** Plans should not repeat information. Reference by section,
    don't duplicate.
11. **Commit messages per task.** Use conventional commit format.
12. **Task dependencies.** Every task declares what it depends on.
13. **Line-range format.** Use `filename.ext:L<start>-L<end>` for modifications.
