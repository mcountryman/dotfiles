{ pkgs, ... }:
{
  imports = [
    ./yubi.nix
    ./nixos/configuration.nix
  ];

  nixpkgs.hostPlatform = "aarch64-linux";

  dotfiles.headless = false;
  dotfiles.users.marvin = {
    email = "me@maar.vin";
    fullName = "Marvin Countryman";
    primary = true;
  };

  environment.systemPackages = with pkgs; [
    bitwarden
  ];

  services.udev.extraRules = ''
    SUBSYSTEM=="backlight", ACTION=="add", MODE="0666", \
      RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"
  '';

  security.pam.services.hyprlock = { };
  services.displayManager.ly.enable = true;
}
