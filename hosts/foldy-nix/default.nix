{ pkgs, ... }:
{
  imports = [
    ./yubi.nix
    ./nixos/configuration.nix
  ];

  nixpkgs.hostPlatform = "aarch64-linux";

  dotfiles.yubi = true;
  dotfiles.headless = false;
  dotfiles.users.marvin = {
    email = "me@maar.vin";
    fullName = "Marvin Countryman";
    primary = true;
  };

  environment.systemPackages = with pkgs; [
    podman
    podman-tui
    bitwarden
    signal-desktop
  ];

  services.udev.extraRules = ''
    SUBSYSTEM=="backlight", ACTION=="add", MODE="0666", \
      RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"
  '';

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  security.pam.services.hyprlock = { };
  services.displayManager.ly.enable = true;
}
