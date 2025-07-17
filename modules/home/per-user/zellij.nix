# zellij - terminal multiplexer
#
# It's like tmux but with a x10 binary size and maybe a few more features that
# I like.

{
  stylix.targets.zellij.enable = true;

  programs.zellij.enable = true;

  xdg.configFile."zellij/config.kdl".source = ./zellij.kdl;
}
