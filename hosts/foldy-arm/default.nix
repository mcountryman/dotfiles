{ pkgs, ... }:
{
  sops.secrets."buildMachines/nix.shramp".sopsFile = ./secrets.yaml;

  nixpkgs.hostPlatform = "aarch64-darwin";

  # is me
  dotfiles.yubi = true;
  dotfiles.users.marvin = {
    email = "me@maar.vin";
    fullName = "Marvin Countryman";
    primary = true;
  };

  # users.users.marvin.extraGroups = [ "video" ];

  services.openssh = {
    enable = true;
  };

  # Random stuff I want on foldy-arm
  environment.systemPackages = with pkgs; [
    mumble
  ];

  homebrew = {
    # brews = [ "docker-buildx" ];
    casks = [
      "steam"
      "firefox"
      "bitwarden"
      # "moonlight"
      # "tailscale"
    ];
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
}
