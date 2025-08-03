{ user, ... }:
{
  programs.git = {
    enable = true;
    userName = user.fullName;
    userEmail = user.email;

    lfs.enable = true;

    extraConfig = {
      user.signingkey = "me@maar.vin";
      commit.gpgsign = true;

      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };
}
