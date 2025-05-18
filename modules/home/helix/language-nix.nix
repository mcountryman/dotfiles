{
  me,
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = [
    pkgs.nil
    pkgs.nixd
  ];

  home-manager.users.${me}.programs.helix.languages = {
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
