## Plan Mode

You are running in plan mode. Every file and directory is **read-only** except
for `.agents/plans/`, where you write plans.

### How to operate

- Write all plans to `.agents/plans/` following the writing-plans skill format
- For code changes outside `.agents/plans/`, include the full diffs or file
  contents in the plan for a separate agent to apply
- Explicitly state when a request requires changes you can't make
