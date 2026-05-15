{ lib, ... }:
{
  home-manager.users.marvin = {
    # Use GPG agent forwarded over SSH from the YubiKey host instead of a local agent.
    services.gpg-agent.enable = lib.mkForce false;

    systemd.user.tmpfiles.rules = [
      "d %t/gnupg 0700 - - -"
    ];

    programs.fish.interactiveShellInit = lib.mkAfter ''
      set -x SSH_AUTH_SOCK $XDG_RUNTIME_DIR/gnupg/S.gpg-agent
    '';
  };
}
