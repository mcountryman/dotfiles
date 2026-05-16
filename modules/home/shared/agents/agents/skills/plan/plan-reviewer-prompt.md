# Plan Document Reviewer

Use this template to self-review the plan before presenting it for sign-off.

**Plan file:** [PLAN_FILE_PATH]

## Checklist

| Category          | What to Check                                                                                                                                                                                          |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| No Placeholders   | Scan for: TBD, TODO, "implement later", "add appropriate error handling", "write tests for the above" without actual code, "similar to Task N" without repeating the code                              |
| Spec Coverage     | Every requirement from the grilling phase maps to at least one task. List any gaps.                                                                                                                    |
| Type Consistency  | Function names, method signatures, property names used in later tasks match what was defined in earlier tasks. A function called `clearLayers()` in Task 3 but `clearFullLayers()` in Task 7 is a bug. |
| Buildability      | Could a skilled-but-unfamiliar developer follow every step without getting stuck? Flag any step that assumes implicit knowledge.                                                                       |
| Verification      | Every task has a runnable verification command with expected output. Flag any task that lacks this.                                                                                                    |
| File Paths        | Every task names exact file paths. Flag any that are vague ("the relevant file").                                                                                                                      |
| Code Completeness | Every code step shows the actual code to write. Flag any that describe what to do without showing how.                                                                                                 |

## Output Format

### Plan Review

**Status:** Approved | Issues Found

**Issues (if any):**

- [Task X, Step Y]: specific issue — why it matters for implementation

**Recommendations (advisory, do not block approval):**

- suggestions for improvement
