{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ruff
    python3Packages.jedi-language-server
  ];

  programs.helix.languages = {
    language = [
      {
        name = "python";
        auto-format = true;
      }
    ];
  };
}
