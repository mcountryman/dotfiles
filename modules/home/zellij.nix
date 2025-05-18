{ me, ... }:
{
  home-manager.users.${me} = {
    stylix.targets.zellij.enable = true;

    programs.zellij.enable = true;

    xdg.configFile."zellij/config.kdl".source = ./zellij.kdl;
  };
}
