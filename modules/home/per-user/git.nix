{ user, ... }:
{
  programs.git = {
    enable = true;
    userName = user.fullName;
    userEmail = user.email;

    lfs.enable = true;

    extraConfig = {
      user.signingkey = "me@maar.vin";
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };

  # Make gpg and ykman play nicely
  home.file.".gnupg/scdaemon.conf".text = ''
    disable-ccid
  '';
}
