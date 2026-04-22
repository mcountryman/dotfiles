# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal Nix Flakes dotfiles managing macOS (nix-darwin) and NixOS system configurations declaratively. Currently only the `foldy-arm` (aarch64-darwin) host is active; the `foldy-nix` NixOS config is commented out.

## Applying Configuration

```bash
# macOS (foldy-arm)
darwin-rebuild switch --flake .

# Update flake inputs before switching
nix flake update && darwin-rebuild switch --flake .

# NixOS (foldy-nix) — currently commented out in flake.nix
sudo nixos-rebuild switch --flake .
```

There are no other build scripts, Makefiles, or test commands — the entire system is managed through `darwin-rebuild`/`nixos-rebuild`.

## Checks and Formatting

**Always run these after modifying any `.nix` file:**

```bash
# Run all checks (formatting, linting, dead code, config eval)
nix flake check

# Auto-format all .nix files
nix fmt
```

Checks are defined in `checks.nix` and wired into `flake.nix` as `outputs.checks`. They run on `aarch64-darwin`, `aarch64-linux`, and `x86_64-linux`.

| Check | Tool | What it catches |
|---|---|---|
| `formatting` | nixfmt-rfc-style | Style inconsistencies — fix with `nix fmt` |
| `statix` | statix | Anti-patterns and style issues |
| `deadnix` | deadnix | Unused bindings and lambda arguments |
| `darwinConfigurations` | nix eval | Module type errors, missing options, bad references in all `aarch64-darwin` hosts — evaluates without building |

The `darwinConfigurations` check runs on every platform: on a matching host it evaluates the config's derivation graph; on others it skips gracefully.

## Architecture

### Module Layers

Modules are composed in `flake.nix` under `darwinModules.default` in this order:

1. **`modules/`** — defines custom `dotfiles.*` options (users attrSet, `yubi` bool, `headless` bool)
2. **`modules/home/`** — wires home-manager; per-user configs live in `modules/home/per-user/`
3. **`modules/shared/`** — cross-platform: fish shell, fonts/stylix theming, nix-daemon settings
4. **`modules/darwin/`** — macOS only: yabai WM, skhd keybinds, homebrew, linux-builder, jankyborders

Host-specific config lives in `hosts/<hostname>/` and sets `dotfiles.*` option values that the modules consume.

### Key Design Decisions

- **Inputs are only accessed from `flake.nix`** — modules do not receive `inputs` to avoid circular reference issues. Any new flake input must be wired through `flake.nix` directly.
- **Theming is centralized via stylix** — gruvbox-dark-hard (base16) applied globally. Theme changes belong in `modules/shared/stylish.nix`, not per-app configs.
- **Secrets via sops-nix** — encrypted with age keys defined in `.sops.yaml`. Per-host `secrets.yaml` files hold sensitive values.
- **Overlays** live in `overlays/` and are imported in `flake.nix`; the helix overlay is added separately from the flake input.

### Home Manager Per-User

`modules/home/per-user/` contains individual tool configs applied to each user via `mapAttrs`. Notable configs:
- `helix/` — primary editor, LSP-heavy config (Nix, Rust, Python, JS, TOML, YAML, HCL, Typst)
- `git.nix` — GPG signing, LFS, auto-setup-remote
- `gpg.nix` — YubiKey (disable-ccid), SSH via gpg-agent
- `tmux.nix` / `zellij.nix` — both configured; tmux uses hjkl navigation, `\` and `-` splits, `f` for yazi popup
- `ghostty.nix` / `alacritty.nix` — both configured terminals
- `firefox/` — active on Linux (LibreWolf), disabled on macOS

### Adding a New Module

1. Create the `.nix` file in the appropriate `modules/` subdirectory
2. Add an `imports` entry in the relevant `default.nix` or the module collection file for that layer
3. If it needs a flake input, wire it through `flake.nix` (not the module itself)
