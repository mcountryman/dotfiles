{ pkgs, ... }:
let
  adminGroupLinux = "@wheel";
  adminGroupDarwin = "@admin";
  adminGroup = if pkgs.stdenv.isLinux then adminGroupLinux else adminGroupDarwin;
in
{
  nix.settings = {
    # This should be the default but, alas
    experimental-features = "nix-command flakes";
    # Allow remote deployments.
    trusted-users = [
      "root"
      adminGroup
    ];
  };

  nixpkgs.config.allowUnfree = true;
}
