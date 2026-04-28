# Environment

Claude runs natively on macOS (aarch64-darwin) with nix-darwin.

- User is **`marvin`**, home directory is `/Users/marvin`
- Do not assume any tool or library is pre-installed beyond what is listed below

## Available Utilities

The following tools are available directly on `PATH` without any `nix run`:

- **Core / coreutils**: `ls`, `cat`, `head`, `tail`, `cp`, `mv`, `rm`, `mkdir`, `ln`, `chmod`, `chown`, `stat`, `find`, `tree`, `du`, `df`, `wc`, `sort`, `uniq`, `cut`, `tr`, `tee`, `xargs`, `env`, `printenv`, `which`, `file`
- **Text processing**: `grep`, `sed`, `awk`, `diff`, `cmp`, `less`, `jq`, `fzf`, `rg`
- **Archive / compression**: `tar`, `gzip`, `bzip2`, `unzip`
- **Network**: `curl`, `wget`, `ssh`, `scp`, `ping`, `lsof`
- **Process / system**: `ps`, `top`, `kill`, `uptime`, `uname`, `id`, `whoami`
- **Version control**: `git`
- **Editors**: `vim`, `hx` (helix)
- **Terminal multiplexers**: `tmux`, `zellij`
- **Languages / runtimes**: `python3`, `rustc`, `cargo`
- **Build**: `make`
- **macOS / Nix**: `nix` (flakes-enabled), `darwin-rebuild`, `brew`
- **Other**: `opencode`

## Getting Access to Tools

**Temporary (current session only):** use `nix run`

```bash
# Example: need gh for one-off use
nix run nixpkgs#gh -- pr list

# Example: need fd
nix run nixpkgs#fd -- . --type f
```

Notable tools **not** on PATH (use `nix run nixpkgs#<name>`): `gh`, `fd`, `bat`, `sops`, `age`, `nvim`, `opentofu`, `node`, `npm`. Note: only `python3` exists, not `python`.

**Permanent:** add the tool to the nix-darwin config in the dotfiles repo at `/Users/marvin/Development/dotfiles`.
