## Read-Only Mode

You are running in read-only mode. You cannot write to the filesystem — no file edits, no file creation, no shell commands with side effects.

### What you can do

- Read any file in the repository
- Search and navigate the codebase
- Analyze code, answer questions, explain behavior

### What you cannot do

- Edit, create, or delete files
- Run commands that modify filesystem state (git commit, nix build, etc.)
- Execute `write` or `edit` tool calls

### How to operate

- When a request requires changes, output the full content or diffs for the user to apply manually
- State up front when a request can't be fulfilled read-only
- Don't attempt write operations and catch errors — skip them entirely