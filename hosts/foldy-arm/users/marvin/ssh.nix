{ config, ... }:
{
  programs.ssh.matchBlocks."orb" = {
    extraOptions.StreamLocalBindUnlink = "yes";
    remoteForwards = [
      {
        bind.address = "/run/user/502/gnupg/S.gpg-agent";
        host.address = "${config.home.homeDirectory}/.gnupg/S.gpg-agent.extra";
      }
    ];
  };
}
