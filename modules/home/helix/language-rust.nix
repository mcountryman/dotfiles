{
  me,
  lib,
  pkgs,
  ...
}: {
  home-manager.users.${me}.programs.helix.languages = {
    language = [
      {
        name = "rust";
        auto-format = true;
        language-servers = [
          "rust-analyzer"
          # "spellcheck"
        ];
        indent = {
          tab-width = 2;
          unit = " ";
        };
      }
    ];
  };
}
