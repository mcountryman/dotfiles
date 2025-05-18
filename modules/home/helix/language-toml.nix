{
  me,
  lib,
  pkgs,
  ...
}: let
  taplo = lib.getExe pkgs.taplo;
in {
  home-manager.users.${me}.programs.helix.languages = {
    language = [
      {
        name = "toml";
        auto-format = true;
        formatter = {
          command = taplo;
          args = ["taplo" "format" "-"];
        };
      }
    ];
  };
}
