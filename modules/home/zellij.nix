{ me, ... }:
{
  home-manager.users.${me} = {
    programs.zellij.enable = true;

    xdg.configFile."zellij/config.kdl".source = ./zellij.kdl;
  };
}
