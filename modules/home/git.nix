{ me, ... }:
{
  home-manager.users.${me}.programs.git = {
    enable = true;
    userName = "Marvin Countryman";
    userEmail = "me@maar.vin";

    extraConfig = {
      core.editor = "hx"; # Probably could be replaced by `$EDITOR`
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };
}
