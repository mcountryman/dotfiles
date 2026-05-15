{
  lib,
  pkgs,
  config,
  ...
}:
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

    # Terminal pinentry is flakey, just use the system one.
    pinentry.package = lib.mkForce pkgs.pinentry_mac;
  };

  # Use gpg's ssh auth sock.
  launchd.agents.gpg-ssh-auth-sock = {
    enable = true;
    config = {
      RunAtLoad = true;
      ProgramArguments = [
        "/bin/launchctl"
        "setenv"
        "SSH_AUTH_SOCK"
        "${config.launchd.agents.gpg-agent.config.Sockets.Ssh.SockPathName}"
      ];
    };
  };
}
