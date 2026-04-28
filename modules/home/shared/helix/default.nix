# helix editor
#
# Ideally done in such a way that LSP/formatter binaries are not on PATH, rather
# directly referenced from the nix store.
{ pkgs, ... }:
{
  imports = [
    ./lsp-ai.nix
    ./lsp-spellcheck.nix

    ./language-git.nix
    ./language-hcl.nix
    ./language-jinja.nix
    ./language-js.nix
    ./language-markdown.nix
    ./language-nix.nix
    ./language-python.nix
    ./language-rust.nix
    ./language-toml.nix
    ./language-typst.nix
    ./language-yaml.nix
  ];

  home.packages = [
    pkgs.bash-language-server
  ];

  programs.helix = {
    enable = true;
    defaultEditor = true;

    settings = {
      theme = "fancy";
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

          space = { };
        };
      };

    };

    themes.fancy = ''
      inherits = "gruvbox_dark_hard"

      "ui.background" = {}
    '';
  };
}
