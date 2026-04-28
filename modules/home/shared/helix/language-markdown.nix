{ pkgs, ... }:
{
  home.packages = with pkgs; [
    deno
    marksman
  ];

  programs.helix.languages = {
    language = [
      {
        name = "markdown";
        auto-format = true;
        formatter = {
          command = "deno";
          args = [
            "fmt"
            "-"
            "--ext"
            "md"
          ];
        };
      }
    ];
  };
}
