{ config, ... }:
{
  users.users = builtins.mapAttrs (_: user: {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  }) config.dotfiles.users;
}
