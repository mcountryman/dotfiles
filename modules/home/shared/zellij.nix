# zellij - terminal multiplexer
{ pkgs, ... }:

let
  sessionSwitcher = pkgs.writeShellScriptBin "zellij-session-switcher" ''
    export PATH="${pkgs.fzf}/bin:${pkgs.zellij}/bin:$PATH"
    exec ${pkgs.nushell}/bin/nu ${./zellij-session-switcher.nu} "$@"
  '';
in
{
  stylix.targets.zellij.enable = true;

  programs.zellij.enable = true;

  xdg.configFile."zellij/config.kdl".source = ./zellij.kdl;

  home.packages = [ sessionSwitcher ];
}
