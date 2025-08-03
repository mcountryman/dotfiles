{ pkgs, ... }:
{
  programs.gpg = {
    enable = true;
    publicKeys = [
      {
        trust = "ultimate";
        source = ./gpg.public_key;
      }
    ];

    # Make gpg and ykman play nicely
    scdaemonSettings.disable-ccid = true;
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;

    pinentry.package = pkgs.pinentry-tty;
  };

  programs.fish.interactiveShellInit = ''
    set -x SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
  '';
}
