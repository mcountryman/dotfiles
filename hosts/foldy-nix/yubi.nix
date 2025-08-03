{ pkgs, ... }:
{
  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];

  # GUI yubi-key management
  environment.systemPackages = with pkgs; [
    gnupg
    yubikey-manager
    yubioath-flutter
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  security.pam.services = {
    sudo.u2fAuth = true;
    login.u2fAuth = true;
  };

  environment.shellInit = ''
    gpg-connect-agent /bye
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  '';
}
