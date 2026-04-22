{ pkgs, ... }:
{
  home.packages = [
    pkgs.typst
    pkgs.typstyle
    pkgs.tinymist
  ];

  programs.helix.languages = {
    language = [
      {
        name = "typst";
        auto-format = true;
        formatter = {
          command = "typstyle";
          args = [ ];
        };
      }
    ];
  };
}
