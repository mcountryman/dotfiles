{ config, ... }:
{
  sops.secrets."buildMachines/nix.shramp".sopsFile = ./secrets.yaml;

  nixpkgs.hostPlatform = "aarch64-darwin";

  # is me
  dotfiles.users.marvin = {
    email = "me@maar.vin";
    fullName = "Marvin Countryman";
    primary = true;
  };

  services.openssh = {
    enable = true;
  };

  # Random stuff I want on foldy-arm
  homebrew = {
    brews = [ "docker-buildx" ];
    casks = [
      "steam"
      "moonlight"
      "tailscale"
    ];
  };

  nix.settings.builders-use-substitutes = true;
  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      system = "x86_64-linux";
      sshKey = config.sops.secrets."buildMachines/nix.shramp".path;
      sshUser = "provision";
      hostName = "nix.shramp";
      supportedFeatures = [
        "nixos-test"
        "big-parallel"
        "kvm"
      ];
    }
  ];
}
