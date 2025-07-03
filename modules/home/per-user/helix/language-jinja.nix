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

    language = [
      {
        name = "jinja";
        auto-format = true;
        language-servers = [
          "jinja-lsp"
          "spellcheck"
        ];
        indent = {
          tab-width = 2;
          unit = " ";
        };

        formatter = {
          command = lib.getExe pkgs.djlint;
          args = [
            "--extension=html.j2"
            "--indent"
            "2"
            "--indent-js"
            "2"
            "--indent-css"
            "2"
            "--reformat"
            "-"
          ];
        };
      }
    ];
  };
}
