{ pkgs, ... }:
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
}
