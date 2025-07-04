{ lib, pkgs, ... }:
{
  programs.helix.languages = {
    language-server.jinja-lsp = {
      command = "${lib.getExe pkgs.jinja-lsp}";
      config = {
        lang = "rust";
        backend = [ "./src" ];
        templates = "./templates";
      };
      timeout = 5;
    };

    language-server.tailwindcss = {
      command = "${lib.getExe pkgs.tailwindcss-language-server}";
      args = [ "--stdio" ];
      config = {
        userLanguages = {
          jinja = "html";
          "*.jinja" = "html";
        };
      };
    };

    language = [
      {
        name = "jinja";
        auto-format = true;
        language-servers = [
          "jinja-lsp"
          "spellcheck"
          "tailwindcss"
        ];
        indent = {
          tab-width = 2;
          unit = " ";
        };
      }
    ];
  };
}
