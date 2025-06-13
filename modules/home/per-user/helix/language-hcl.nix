{ lib, pkgs, ... }:
{
  home.packages = [
    pkgs.terraform-ls
  ];

  programs.helix.languages = {
    language = [
      {
        name = "hcl";
        auto-format = true;
        formatter = {
          command = lib.getExe pkgs.opentofu;
          args = [
            "fmt"
            "-"
          ];
        };
      }
    ];
  };
}
