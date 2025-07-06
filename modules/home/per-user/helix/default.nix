{ lib, pkgs, ... }:
{
  imports = [
    ./language-hcl.nix
    ./language-jinja.nix
    ./language-js.nix
    ./language-nix.nix
    ./language-rust.nix
    ./language-toml.nix
    ./language-yaml.nix
  ];

  home.packages = [
    pkgs.bash-language-server

    (pkgs.vale.withStyles (s: [ s.google ]))
  ];

  programs.helix = {
    enable = true;
    defaultEditor = true;

    languages = {
      language-server.spellcheck = {
        command = "${lib.getExe pkgs.codebook}";
        args = [ "serve" ];
      };
    };

    settings = {
      theme = "ayu_dark";
      editor = {
        mouse = false;
        shell = [
          "fish"
          "-c"
        ];
        rulers = [ 80 ];
        bufferline = "always";
        cursorline = true;
        line-number = "relative";
        true-color = true;

        lsp = {
          # display-messages = true;
          display-inlay-hints = true;
        };

        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };

        file-picker = {
          hidden = false;
        };

        indent-guides = {
          render = true;
          character = "┊";
        };

        statusline = {
          left = [
            "mode"
            "diagnostics"
          ];
          right = [
            "selections"
            "position"
          ];
          center = [
            "file-name"
            "file-modification-indicator"
          ];
        };
      };

      keys = {
        normal = {
          "esc" = [
            "keep_primary_selection"
            "collapse_selection"
          ];
          left = "no_op";
          down = "no_op";
          up = "no_op";
          right = "no_op";

          space = {
            # z = ":sh zellij run -fc -x 10% --width 80% -- bash ~/.config/helix/bin/yazi";
            # "/" = ":sh zellij run -fc -x 10% --width 80% -- bash ~/.config/helix/bin/ff";
          };
        };
      };
    };
  };
}
