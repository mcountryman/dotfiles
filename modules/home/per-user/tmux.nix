{ pkgs, ... }:
{
  stylix.targets.tmux.enable = true;

  programs.tmux = {
    enable = true;
    mouse = true;
    package = pkgs.tmux.override { withSixel = true; };
    plugins = with pkgs; [
      tmuxPlugins.sensible
      tmuxPlugins.gruvbox
      tmuxPlugins.minimal-tmux-status # could probably do this by hand..
    ];

    extraConfig = ''
      # term
      set -g default-shell "${pkgs.fish}/bin/fish"
      set -g default-command "${pkgs.fish}/bin/fish -l"
      set -g default-terminal "tmux-256color"
      set -ga terminal-overrides '*:Ss=\E[%p1%d q:Se=\E[ q'
      set-environment -g COLORTERM "truecolor"
      set -g allow-passthrough on
      set -ga update-environment TERM
      set -ga update-environment TERM_PROGRAM
      set -ag terminal-overrides ",xterm-256color:RGB"

      # theme
      set -g @tmux-gruvbox 'dark256'
      set -g @tmux-gruvbox-statusbar-alpha 'true'
      # set -g @tmux-gruvbox-left-status-a '#S' # tmux's session name
      # set -g @tmux-gruvbox-right-status-x '%Y-%m-%d'
      set -g @minimal-tmux-fg "#fbf1c7"
      set -g @minimal-tmux-bg "#98971a"
      set -g @minimal-tmux-status-right-extra " "
      set -g status-style bg=default,fg=default

      # style
      set -g pane-border-style "fg=#458588"
      set -g pane-active-border-style "fg=#83a598"
        
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

      bind f display-popup -h 50% -w 60% -E "sh -c 'SESSION_NAME=Yazi; if ! tmux has-session -t \$SESSION_NAME 2>/dev/null; then tmux new-session -d -s \$SESSION_NAME -c \"#{pane_current_path}\" yazi; tmux set-option -t \$SESSION_NAME status off; fi; tmux attach-session -t \$SESSION_NAME'"

      bind R source ~/.config/tmux/tmux.conf
      unbind '"'
      unbind %
    '';
  };
}
