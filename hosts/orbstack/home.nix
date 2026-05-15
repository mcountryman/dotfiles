{ lib, ... }:
{
  home-manager.users.marvin = {
    services.gpg-agent = {
      enable = lib.mkForce false;
    };
  };
}
