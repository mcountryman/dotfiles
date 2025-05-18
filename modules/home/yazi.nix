{ me, ... }:

{
  home-manager.users.${me} = {
    stylix.targets.yazi.enable = true;

    programs.yazi = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
