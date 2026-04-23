{ lib, ... }:
{
  home.username = "marvin";
  home.homeDirectory = "/Users/marvin";

  # YubiKey host: override SSH auth to use gpg-agent socket
  programs.fish.interactiveShellInit = lib.mkAfter ''
    gpg-connect-agent /bye
    set -x SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
  '';
}
