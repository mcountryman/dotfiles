{ user, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user.name = user.fullName;
      user.email = user.email;
      user.signingkey = "me@maar.vin";

      commit.gpgsign = true;

      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };

    lfs.enable = true;
  };
}
