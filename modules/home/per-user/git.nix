{ user, ... }:
{
  programs.git = {
    enable = true;
    userName = user.fullName;
    userEmail = user.email;

    lfs.enable = true;

    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };
}
