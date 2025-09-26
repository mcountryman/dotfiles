{ pkgs, ... }:
{
  imports = [
    ./yubi.nix
    ./graphics.nix
    ./goose-cli.nix
    ./nixos/configuration.nix
  ];

  nixpkgs.hostPlatform = "aarch64-linux";
  nixpkgs.config.allowUnfree = true;

  dotfiles.yubi = true;
  dotfiles.headless = false;
  dotfiles.users.marvin = {
    email = "me@maar.vin";
    fullName = "Marvin Countryman";
    primary = true;
  };

  environment.systemPackages = with pkgs; [
    bitwarden
    signal-desktop
    qemu
  ];

  services.udev.extraRules = ''
    SUBSYSTEM=="backlight", ACTION=="add", MODE="0666", \
      RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"
  '';

  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = toString (1024 * 1024);
    }
  ];

  boot.binfmt.emulatedSystems = [ "x86_64-linux" ];

  security.pam.services.hyprlock = { };
  services.displayManager.ly.enable = true;

  services.pipewire.jack.enable = true;

  virtualisation.docker = {
    enable = true;
  };

  users.users.marvin.extraGroups = [ "docker" ];
}
