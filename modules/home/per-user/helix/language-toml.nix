{ lib, pkgs, ... }:
{
  programs.helix.languages = {
    language = [
      {
        name = "toml";
        auto-format = true;
        formatter = {
          command = lib.getExe pkgs.taplo;
          args = [
            "taplo"
            "format"
            "-"
          ];
        };
      }
    ];
  };
}
