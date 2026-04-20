{ pkgs, config, ... }:
{
  # Enable alternative shell support in nix-darwin.
  programs.fish.enable = true;
  # Set the user's login shell
  users.users = builtins.mapAttrs (_: _: { shell = "${pkgs.fish}/bin/fish"; }) config.dotfiles.users;
}
