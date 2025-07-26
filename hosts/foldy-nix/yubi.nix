{ pkgs, ... }:
{
  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];

  # GUI yubi-key management
  environment.systemPackages = with pkgs; [ yubioath-flutter ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  security.pam.services = {
    sudo.u2fAuth = true;
    login.u2fAuth = true;
  };
}
