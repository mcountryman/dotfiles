{ pkgs, ... }:
{
  sops.secrets."buildMachines/nix.shramp".sopsFile = ./secrets.yaml;

  nixpkgs.hostPlatform = "aarch64-darwin";

  home-manager.users.marvin.imports = [ ./users/marvin ];

  services.openssh = {
    enable = true;
  };

  # Random stuff I want on foldy-arm
  environment.systemPackages = with pkgs; [
    mumble
  ];

  homebrew = {
    casks = [
      "steam"
      "firefox"
      "bitwarden"
    ];
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
}
