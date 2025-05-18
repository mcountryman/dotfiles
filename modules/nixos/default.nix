{
  me,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (pkgs.targetPlatform) isLinux isDarwin;
in
{
  imports = [
    ./fonts.nix
    ./stylish.nix
  ];

  nix = {
    # I forget why I did this.
    settings.trusted-users = [
      "root"
      me
    ];
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

  users.users.${me} =
    { } // (mkIf isLinux { isNormalUser = true; }) // (mkIf isDarwin { home = "/Users/marvin"; })
  # ..
  ;
}
