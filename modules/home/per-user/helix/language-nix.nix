{ lib, pkgs, ... }:
{
  home.packages = [
    pkgs.nil
    pkgs.nixd
  ];

  programs.helix.languages = {
    language = [
      {
        name = "nix";
        auto-format = true;
        # formatter.command = lib.getExe pkgs.nixfmt-classic;
        formatter.command = lib.getExe pkgs.nixfmt-rfc-style;
        # formatter.command = lib.getExe pkgs.alejandra;
      }
    ];
  };
}
