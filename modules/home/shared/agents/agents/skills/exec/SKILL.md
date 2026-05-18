---
name: exec
description: >
  Executes implementation plans created by the plan skill. Reads a plan from
  .agents/plans/, validates it, then delegates each task to a sub-agent.
  Supports parallel execution of independent tasks, stop-on-failure, and
  resume from previously completed tasks. Use when the user says "execute
  the plan", "run the plan", "execute-plan", or invokes /execute-plan.
---

# Exec Skill

**Announce at start:** "I'm using the exec skill to execute the
implementation plan."

## Constraints

- This skill only executes plans. It does not create or modify them.
- Plans are read from `$PWD/.agents/plans/`.
- The user must specify which plan file to execute.
- Stop execution immediately if any task fails.
- Resume is supported: skip tasks whose steps are already checked off.

## Workflow

### Phase 1: Setup

1. Announce: "I'm using the exec skill to execute the
   implementation plan."
2. Ask the user to specify the plan file path relative to
   `$PWD/.agents/plans/` (e.g., `my-feature.md`).
3. Read the plan file from `.agents/plans/<plan-file>`.
4. Validate the plan:
   - File exists and is readable
   - Contains a `## Tasks` section
   - Contains at least one `### Task N:` heading
   - Each task has at least one step with a `[ ]` checkbox
   - If validation fails, report the issue and stop.

### Phase 2: Build Execution Plan

1. Parse all tasks from the plan file.
2. For each task, determine:
   - Task name and number
   - Dependency (from `**Depends on:**` line)
   - Whether all steps are already completed (all checkboxes are `[x]`)
3. Build the dependency graph:
   - Tasks with `**Depends on:** None` have no dependencies.
   - Tasks with `**Depends on:** Task N` depend on Task N completing first.
   - Tasks with `**Depends on:** Task N, Task M` depend on both.
4. Identify execution batches:
   - Batch 1: All tasks with no unmet dependencies (excluding
     already-completed tasks)
   - Batch 2: Tasks whose dependencies are all in Batch 1
   - Continue until all tasks are assigned to a batch.
5. Skip any tasks where all steps are already `[x]` (completed).
6. Present the execution plan to the user showing batches and which tasks
   will run in parallel. Ask for confirmation before proceeding.

### Phase 3: Execute

For each batch:

1. **Spawn sub-agents for all tasks in the batch concurrently** using the
   `task` tool for each task:

   ```
   subagent_type: "general"
   description: "Execute <Task Name>"
   prompt: |
     You are executing Task N from an implementation plan. Your task:

     <paste the entire task section including all steps, code blocks, and
     verification commands>

     Context from the plan:
     - Goal: <paste plan's Goal line>
     - Architecture: <paste plan's Architecture section>

     Quality tools for this task:
     <paste the Quality Tools table rows relevant to files touched by this
     task>

     Style exemplars for this task:
     <paste the Style Exemplars table rows relevant to files touched by this
     task>

     Instructions:
     1. Execute every step in order. Do not skip steps.
     2. For test steps: write the test, run it, verify it fails, then
        implement, then verify it passes.
     3. For quality verification steps: run ALL applicable quality tools.
        Every tool must pass.
     4. For style conformance: compare your code against the exemplars.
        Verify naming, structure, and idiomatic patterns match.
     5. For commit steps: commit exactly as specified with the given
        message.
     6. If any step fails, report the failure clearly and stop. Do not
        attempt to fix issues beyond the plan's instructions.
     7. Do not modify the plan file.
   ```

2. **Wait for all sub-agents in the batch to complete.**

3. **Check results:**
   - If all sub-agents reported success, mark all steps in each task as
     completed by changing `[ ]` to `[x]` in the plan file. Include
     timestamps in the format `YYYY-MM-DD HH:MM` next to each checkbox.
   - If any sub-agent reported failure:
     1. Report the failure to the user with the task name and error details.
     2. Do NOT mark steps as completed for the failed task.
     3. Stop execution. Do not proceed to subsequent batches.

4. **Proceed to the next batch** (if all succeeded).

### Phase 4: Summary

After all batches complete (or execution stops on failure):

1. Report execution summary:
   - Total tasks: N
   - Completed: N
   - Failed: N (if any)
   - Skipped (already done): N (if any)
2. If all tasks completed successfully, confirm the plan is fully executed.
3. If execution stopped on failure, explain what failed and suggest next
   steps (e.g., fix the issue and re-run the skill to resume).

## Resume Behavior

When re-invoked on a plan with partially completed tasks:

1. Parse the plan file and identify all `[x]` checkboxes as completed steps.
2. A task is considered "completed" if ALL its step checkboxes are `[x]`.
3. A task is considered "partial" if some but not all checkboxes are `[x]`.
4. For partial tasks, re-execute the entire task (sub-agent will need to
   redo incomplete steps; completed steps should pass quickly on re-run).
5. Skip fully completed tasks entirely.
6. Inform the user which tasks will be skipped and which will be
   (re-)executed.

## Rules

1. **Never modify the plan's content or structure** — only update checkbox
   states and timestamps.
2. **Never skip steps** — sub-agents must execute every step in a task.
3. **Stop on any failure** — do not continue to subsequent batches.
4. **Commit as specified** — each task's commit step must be executed.
5. **Parallelize within batches** — independent tasks run concurrently.
6. **Respect dependencies** — never execute a task before its dependencies.
7. **Report clearly** — the user must understand what succeeded and what
   failed.
