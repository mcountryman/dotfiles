{ config, ... }:
{
  users.users = builtins.mapAttrs (_: _: {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  }) config.dotfiles.users;
}
