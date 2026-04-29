{ lib, pkgs, ... }:

let
  inherit (lib) getExe;

  pickSession =
    with pkgs;
    writeShellScriptBin "tmux-pick-session" ''
      #!/bin/sh
      session=$(tmux list-sessions 2>/dev/null | cut -d: -f1 | ${getExe fzf} --reverse --no-multi --prompt="session> ")

      if [ -n "$session" ]; then
          ${getExe tmux} switch-client -t "$session"
      fi
    '';
in
{
  stylix.targets.tmux.enable = true;

  programs.tmux = {
    enable = true;
    mouse = true;
    plugins = with pkgs; [
      tmuxPlugins.sensible
      {
        plugin = tmuxPlugins.gruvbox;
        extraConfig = ''
          set -g @tmux-gruvbox 'dark256'
          set -g @tmux-gruvbox-statusbar-alpha 'true'
        '';
      }
      {
        plugin = tmuxPlugins.minimal-tmux-status;
        extraConfig = ''
          set -g @minimal-tmux-fg "#fbf1c7"
          set -g @minimal-tmux-bg "#98971a"
          set -g @minimal-tmux-status-right-extra " "
          set -g @minimal-tmux-left false
          set -g @minimal-tmux-right false
          set -g @minimal-tmux-use-arrow true
          set -g @minimal-tmux-indicator-str " TMUX "
        '';
      }
    ];

    extraConfig = ''
      # term
      set -g default-shell "${pkgs.fish}/bin/fish"
      set -g default-command "${pkgs.fish}/bin/fish -l"
      set -g allow-passthrough on
      set -ga update-environment TERM_PROGRAM

      # input
      set -g set-clipboard external

      # theme
      set -g status-style bg=#1d2021,fg=default

      # style
      set-window-option -g pane-border-status off
      set -g pane-border-style "fg=#504945"
      set -g pane-active-border-style "fg=#504945"
      set -g window-active-style "bg=default"
      set -g popup-border-lines rounded
      set -g popup-style "bg=#1d2021"

      # keys — prefix mode (Ctrl+b then key)
      bind \\ split-window -h -c "#{pane_current_path}"
      bind -  split-window -v -c "#{pane_current_path}"
      bind h  select-pane -L
      bind j  select-pane -D
      bind k  select-pane -U
      bind l  select-pane -R

      bind f display-popup  -h 50% -w 60% -e TERM_PROGRAM=ghostty -d "#{pane_current_path}" -E "${getExe pkgs.yazi} 2>/dev/null"
      bind Space display-popup -b rounded -w 60% -h 40% -x C -y C -E "${getExe pkgs.fish}/bin/fish"

      bind c new-window
      bind , command-prompt -I '#W' -p 'rename:' 'rename-window %%'
      bind p previous-window
      bind n next-window
      bind d detach-client
      bind x kill-pane
      bind z resize-pane -Z
      bind s display-popup -b rounded -h 50% -w 60% -x C -y C -E "${getExe pickSession}"
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
    '';
  };
}
