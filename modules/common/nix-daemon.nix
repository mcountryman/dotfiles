{ lib, config, ... }:
let
  inherit (lib) pipe;
  inherit (builtins) attrValues;

  usernames = pipe config.dotfiles.users [
    attrValues
    (map (u: u.name))
  ];
in
{
  nix = {
    # Allows remote deployments for these users.
    settings.trusted-users = [ "root" ] ++ usernames;
    # Necessary for using flakes on this system.
    settings.experimental-features = "nix-command flakes";
  };

  # nixpkgs = {
  #   # There was a nixpkg that was mistakenly marked broken for darwin.  This was
  #   # my hack fix at the time.  Now I'd consider an overlay or something.
  #   config.allowBroken = true;
  #   # I don't like having money.
  #   config.allowUnfree = true;
  # };
}
