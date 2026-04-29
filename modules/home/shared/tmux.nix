{ pkgs, ... }:
{
  stylix.targets.tmux.enable = true;

  home.packages = with pkgs; [
    (writeShellScriptBin "tmux-pick-session" ''
      tmux list-sessions 2>/dev/null |
      cut -d: -f1 |
      ${gum}/bin/gum choose --height 40 --header "switch:" |
      xargs -I {} tmux switch-client -t {}
    '')
  ];

  programs.tmux = {
    enable = true;

    # TODO: upgrade to nixos-25.11
    #
    # This is a temporary fix to avoid having to upgrade to 25.11 yet. If it
    # wasn't for the need of two different nixpkgs for darwin and linux I'd
    # just do it.
    package = pkgs.tmux.overrideAttrs (
      final: _prev: {
        version = "3.6a";
        src = pkgs.fetchFromGitHub {
          owner = "tmux";
          repo = "tmux";
          rev = final.version;
          hash = "sha256-VwOyR9YYhA/uyVRJbspNrKkJWJGYFFktwPnnwnIJ97s=";
        };
      }
    );

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
          set -g @minimal-tmux-status-left " #{?client_key_table,#{client_key_table},} "
          set -g @minimal-tmux-status-right-extra " "
        '';
      }
    ];

    extraConfig = ''
      # term
      set -g allow-passthrough on
      set -g default-terminal "''${TERM}"
      set -ag terminal-overrides ",''${TERM}:Tc"
      set -g default-shell "${pkgs.fish}/bin/fish"
      set -g default-command "${pkgs.fish}/bin/fish -l"

      # input
      set -g set-clipboard external

      # theme
      set -g status-style bg=#1d2021,fg=default

      # style
      set-window-option -g pane-border-status off
      set -g pane-border-style "fg=#504945"
      set -g pane-active-border-style "fg=#504945"
      set -g window-active-style "bg=default"
      set -g popup-border-lines single
      set -g popup-style "bg=default"

      # keys — prefix mode (Ctrl+b then key)
      bind \\ split-window -h -c "#{pane_current_path}"
      bind -  split-window -v -c "#{pane_current_path}"
      bind h  select-pane -L
      bind j  select-pane -D
      bind k  select-pane -U
      bind l  select-pane -R

      bind f     display-popup -w 60% -h 50% -E -d "#{pane_current_path}" "tmux new-session 'tmux set status off && yazi'"
      bind s     display-popup -w 80  -h 20  -E "tmux-pick-session"
      bind Space display-popup -w 60% -h 50% -E "fish -l"

      bind c new-window
      bind , command-prompt -I '#W' -p 'rename:' 'rename-window %%'
      bind p previous-window
      bind n next-window
      bind d detach-client
      bind x kill-pane
      bind z resize-pane -Z
      bind r switch-client -T resize
      bind [ copy-mode

      bind R source ~/.config/tmux/tmux.conf
      unbind '"'
      unbind %

      # keys — resize mode (prefix+r to enter, Esc/Enter to exit)
      bind -T resize h resize-pane -L 5 \; switch-client -T resize
      bind -T resize j resize-pane -D 5 \; switch-client -T resize
      bind -T resize k resize-pane -U 5 \; switch-client -T resize
      bind -T resize l resize-pane -R 5 \; switch-client -T resize
      bind -T resize H resize-pane -L 1 \; switch-client -T resize
      bind -T resize J resize-pane -D 1 \; switch-client -T resize
      bind -T resize K resize-pane -U 1 \; switch-client -T resize
      bind -T resize L resize-pane -R 1 \; switch-client -T resize
      bind -T resize Escape switch-client -T root
      bind -T resize Enter switch-client -T root
    '';
  };
}
