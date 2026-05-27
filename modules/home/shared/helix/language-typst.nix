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
        language-servers = [
          "spellcheck"
          "tinymist"
        ];

        auto-format = true;
        formatter = {
          command = "typstyle";
          args = [
            "-l"
            "80"
            "--wrap-text"
          ];
        };
      }
    ];
  };
}
