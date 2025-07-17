{ lib, config, ... }:
let
  inherit (lib) pipe;
  inherit (builtins) attrValues;

  # One would assume all users I add are administrators.  I'll probably forget
  # that come that day so fingers crossed I see this comment when I do that.
  usernames = pipe config.dotfiles.users [
    attrValues
    (map (u: u.name))
  ];
in
{
  nix = {
    # Allows remote deployments for these users.
    settings.trusted-users = [ "root" ] ++ usernames;
    # This should be the default but, alas
    settings.experimental-features = "nix-command flakes";
  };
}
