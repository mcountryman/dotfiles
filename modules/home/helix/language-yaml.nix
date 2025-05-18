{
  me,
  lib,
  pkgs,
  ...
}: let
  prettier = lib.getExe pkgs.nodePackages.prettier;
in {
  environment.systemPackages = [
    pkgs.yaml-language-server
  ];

  home-manager.users.${me}.programs.helix.languages = {
    language = [
      {
        name = "yaml";
        auto-format = true;
        formatter = {
          command = prettier;
          args = ["--parser" "yaml"];
        };
      }
    ];
  };
}
