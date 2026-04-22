{ user, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        inherit (user) email;

        name = user.fullName;
        signingkey = "me@maar.vin";
      };

      commit.gpgsign = true;

      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };

    lfs.enable = true;
  };
}
