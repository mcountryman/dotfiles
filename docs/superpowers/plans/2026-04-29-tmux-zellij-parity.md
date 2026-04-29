# tmux Zellij Parity Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reconfigure tmux to visually and behaviorally match the zellij compact-layout experience with modal keybindings, floating popups, and session switching.

**Architecture:** Modify the existing `tmux.nix` home-manager module to add modal key tables (resize, copy-mode-vi), a session switcher popup, a scratchpad popup, new tab management bindings, and compact status bar configuration. Add a `tmux-session-switcher` shell script alongside the file. Keep existing plugins (gruvbox, minimal-tmux-status, sensible).

**Tech Stack:** Nix home-manager, tmux 3.5a, fish, fzf

---

### Task 1: Create tmux-session-switcher script

**Files:**
- Create: `modules/home/shared/tmux-session-switcher.sh`

- [ ] **Step 1: Create the session switcher script**

Create `modules/home/shared/tmux-session-switcher.sh` with the following content:

```bash
#!/bin/sh
# tmux-session-switcher — interactive session switcher using fzf
# Lists tmux sessions, opens fzf for selection, switches to the chosen session.
# Exits cleanly on Escape/Ctrl-C (fzf returns empty).

session=$(tmux list-sessions 2>/dev/null | cut -d: -f1 | fzf --reverse --no-multi --prompt="session> ")

if [ -n "$session" ]; then
    tmux switch-client -t "$session"
fi
```

- [ ] **Step 2: Package the script in tmux.nix**

Add a `let` block to package the script. In `modules/home/shared/tmux.nix`, change the top of the file from:

```nix
{ pkgs, ... }:
{
```

to:

```nix
{ pkgs, ... }:

let
  tmuxSessionSwitcher = pkgs.writeShellScriptBin "tmux-session-switcher" (builtins.readFile ./tmux-session-switcher.sh);
in
{
```

Then add `tmuxSessionSwitcher` to `home.packages` by adding this inside the `programs.tmux` block, after the `extraConfig` closing quote:

```nix
  home.packages = [ tmuxSessionSwitcher ];
```

The full file at this point should look like:

```nix
{ pkgs, ... }:

let
  tmuxSessionSwitcher = pkgs.writeShellScriptBin "tmux-session-switcher" (builtins.readFile ./tmux-session-switcher.sh);
in
{
  stylix.targets.tmux.enable = true;

  programs.tmux = {
    enable = true;
    mouse = true;
    plugins = with pkgs; [
      tmuxPlugins.sensible
      tmuxPlugins.gruvbox
      tmuxPlugins.minimal-tmux-status
    ];

    extraConfig = ''
      # term
      set -g default-shell "${pkgs.fish}/bin/fish"
      set -g default-command "${pkgs.fish}/bin/fish -l"

      # input
      set -g set-clipboard external

      # theme
      set -g @tmux-gruvbox 'dark256'
      set -g @tmux-gruvbox-statusbar-alpha 'true'
      set -g @minimal-tmux-fg "#fbf1c7"
      set -g @minimal-tmux-bg "#98971a"
      set -g @minimal-tmux-status-right-extra " "
      set -g status-style bg=#1d2021,fg=default

      # style
      set-window-option -g pane-border-status off
      set -g pane-border-style "fg=colour235,bg=colour235"
      set -g pane-active-border-style "fg=colour235,bg=colour235"
      set -g window-active-style "bg=#282828"

      # keys
      bind \\ split-window -h -c "#{pane_current_path}"
      bind -  split-window -v -c "#{pane_current_path}"
      bind h  select-pane -L
      bind j  select-pane -D
      bind k  select-pane -U
      bind l  select-pane -R
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      bind f display-popup -d "#{pane_current_path}" -h 50% -w 60% -E "sh -c 'yazi'"

      bind R source ~/.config/tmux/tmux.conf
      unbind '"'
      unbind %
    '';
  };

  home.packages = [ tmuxSessionSwitcher ];
}
```

- [ ] **Step 3: Run nix flake check**

Run: `nix flake check`
Expected: PASS (no evaluation errors)

- [ ] **Step 4: Commit**

```bash
git add modules/home/shared/tmux-session-switcher.sh modules/home/shared/tmux.nix
git commit -m "feat(tmux): add session switcher script"
```

---

### Task 2: Add compact status bar and popup styling

**Files:**
- Modify: `modules/home/shared/tmux.nix`

- [ ] **Step 1: Add compact status bar and popup config**

In `modules/home/shared/tmux.nix`, add the following lines inside the `extraConfig` string, after the `set -g status-style bg=#1d2021,fg=default` line (under the `# theme` section):

```
      # compact bar
      set -g @minimal-tmux-left false
      set -g @minimal-tmux-right false
      set -g @minimal-tmux-use-arrow true
      set -g @minimal-tmux-indicator-str " TMUX "
```

And add the following lines after the `set -g window-active-style "bg=#282828"` line (under the `# style` section):

```
      set -g popup-border-lines rounded
      set -g popup-style "bg=#282828"
```

The `# style` section should now look like:

```
      # style
      set-window-option -g pane-border-status off
      set -g pane-border-style "fg=colour235,bg=colour235"
      set -g pane-active-border-style "fg=colour235,bg=colour235"
      set -g window-active-style "bg=#282828"
      set -g popup-border-lines rounded
      set -g popup-style "bg=#282828"
```

- [ ] **Step 2: Run nix flake check**

Run: `nix flake check`
Expected: PASS

- [ ] **Step 3: Commit**

```bash
git add modules/home/shared/tmux.nix
git commit -m "feat(tmux): compact status bar and popup styling"
```

---

### Task 3: Add modal key system with resize mode

**Files:**
- Modify: `modules/home/shared/tmux.nix`

- [ ] **Step 1: Add resize mode key table**

In `modules/home/shared/tmux.nix`, add the following lines inside the `extraConfig` string, replacing the existing `# keys` section. The old `H/J/K/L` prefix-table resize bindings should be removed (they're replaced by the resize mode's lowercase h/j/k/l and uppercase H/J/K/L). Add the tab management bindings and resize mode key table:

Replace the entire `# keys` section (from `# keys` through `unbind %`) with:

```
      # keys — prefix mode (Ctrl+b then key)
      bind \\ split-window -h -c "#{pane_current_path}"
      bind -  split-window -v -c "#{pane_current_path}"
      bind h  select-pane -L
      bind j  select-pane -D
      bind k  select-pane -U
      bind l  select-pane -R

      bind f display-popup -d "#{pane_current_path}" -h 50% -w 60% -E "sh -c 'yazi'"
      bind Space display-popup -b rounded -w 60% -h 40% -x C -y C -E "${pkgs.fish}/bin/fish"

      bind c new-window
      bind , command-prompt -I '#W' -p 'rename:' 'rename-window %%'
      bind p previous-window
      bind n next-window
      bind d detach-client
      bind x kill-pane
      bind z resize-pane -Z
      bind s display-popup -b rounded -h 50% -w 60% -x C -y C -E "tmux-session-switcher"
      bind r switch-client -T resize
      bind [ copy-mode

      bind R source ~/.config/tmux/tmux.conf
      unbind '"'
      unbind %

      # keys — resize mode (prefix+r to enter, Esc/Enter to exit)
      bind -T resize h resize-pane -L 5
      bind -T resize j resize-pane -D 5
      bind -T resize k resize-pane -U 5
      bind -T resize l resize-pane -R 5
      bind -T resize H resize-pane -L 1
      bind -T resize J resize-pane -D 1
      bind -T resize K resize-pane -U 1
      bind -T resize L resize-pane -R 1
      bind -T resize Escape switch-client -T root
      bind -T resize Enter switch-client -T root
```

Note: The four `-r H/J/K/L` lines from the old config are gone — they're replaced by the resize mode bindings.

- [ ] **Step 2: Run nix flake check**

Run: `nix flake check`
Expected: PASS

- [ ] **Step 3: Commit**

```bash
git add modules/home/shared/tmux.nix
git commit -m "feat(tmux): modal key system with resize mode and tab management"
```

---

### Task 4: Validation and manual testing

**Files:**
- None (verification only)

- [ ] **Step 1: Run nix fmt**

Run: `nix fmt`
Expected: No changes or changes auto-formatted

- [ ] **Step 2: Run nix flake check**

Run: `nix flake check`
Expected: All checks pass (formatting, statix, deadnix, darwinConfigurations eval)

- [ ] **Step 3: Apply the configuration**

Run: `darwin-rebuild switch --flake .`
Expected: Successful rebuild, no errors

- [ ] **Step 4: Manual smoke test**

Test these key sequences in a tmux session:

1. **Status bar**: Verify only tabs are shown (left indicator hidden, right session name hidden), active tab has powerline arrows
2. **Resize mode**: `Ctrl+b r` then `h/j/k/L` to resize panes, `Esc` to exit resize mode
3. **Session switcher**: `Ctrl+b s` opens fzf popup, `Esc` closes it
4. **Scratchpad**: `Ctrl+b Space` opens fish popup, exit fish to close
5. **Yazi**: `Ctrl+b f` opens yazi popup (unchanged)
6. **Tab management**: `Ctrl+b c` (new tab), `,` (rename), `p/n` (prev/next), `z` (zoom), `x` (kill pane), `d` (detach)
7. **Popup styling**: Popups should have rounded borders and `#282828` background

- [ ] **Step 5: Commit any formatting fixes if needed**

If `nix fmt` made changes in prior steps:

```bash
git add modules/home/shared/tmux.nix
git commit -m "style(tmux): apply nixfmt formatting"
```