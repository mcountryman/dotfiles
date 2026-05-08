{ lib, pkgs, ... }:
{
  home.packages = [
    pkgs.yaml-language-server
  ];

  programs.helix.languages = {
    language = [
      {
        name = "yaml";
        auto-format = true;
        formatter = {
          command = lib.getExe pkgs.prettier;
          args = [
            "--parser"
            "yaml"
          ];
        };
      }
    ];
  };
}
