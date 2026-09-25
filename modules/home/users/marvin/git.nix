{
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "Marvin Countryman";
        email = "me@maar.vin";
        signingkey = "me@maar.vin";
      };

      signing = {
        key = "me@maar.vin";
        backend = "gpg";
        behavior = "drop";
      };

      git = {
        sign-on-push = true;
      };
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Marvin Countryman";
        email = "me@maar.vin";
        signingkey = "me@maar.vin";
      };

      commit.gpgsign = true;

      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };

    lfs.enable = true;
  };
}
