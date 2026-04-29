{ lib, pkgs, ... }:
{
  imports = [
    ./claude.nix
    ./opencode.nix
  ];

  home.username = "marvin";
  home.homeDirectory = "/Users/marvin";

  services.gpg-agent.pinentry.package = lib.mkForce pkgs.pinentry_mac;

  # YubiKey host: override SSH auth to use gpg-agent socket
  programs.fish.interactiveShellInit = lib.mkAfter ''
    gpg-connect-agent /bye
    set -x SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
  '';
}
