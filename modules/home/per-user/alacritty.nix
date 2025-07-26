# alacritty - GUI terminal emulator

{ pkgs, ... }:
{
  stylix.targets.alacritty.enable = true;

  programs.alacritty = {
    enable = true;
    settings = {
      env = {
        TERM = "xterm-256color";
      };

      terminal.shell = "${pkgs.fish}/bin/fish";

      window = {
        decorations = "buttonless";
        dynamic_padding = false;
      };
    };
  };
}
