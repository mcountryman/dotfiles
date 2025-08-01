{ lib, pkgs, ... }:
let
  # vscode-css = "${pkgs.vscode-langservers-extracted}/bin/vscode-css-language-server";
  # vscode-html = "${pkgs.vscode-langservers-extracted}/bin/vscode-html-language-server";
  vscode-json = "${pkgs.vscode-langservers-extracted}/bin/vscode-json-language-server";
  vscode-eslint = "${pkgs.vscode-langservers-extracted}/bin/vscode-eslint-language-server";
  # vscode-markdown = "${pkgs.vscode-langservers-extracted}/bin/vscode-markdown-language-server";

  typescript = {
    language-servers = [
      "typescript-language-server"
      "eslint"
    ];
    formatter = {
      command = lib.getExe pkgs.nodePackages.prettier;
      args = [
        "--parser"
        "typescript"
      ];
    };
  };
in
{
  home.packages = [
    # This is the base LSP helix is setup to use
    pkgs.typescript-language-server
    # Fingers crossed helix picks this up
    pkgs.vscode-langservers-extracted
  ];

  programs.helix.languages = {
    language-server.eslint = {
      args = [ "--stdio" ];
      command = vscode-eslint;
      config = {
        run = "onType";
        quiet = false;
        format = {
          enable = true;
        };
        nodePath = "";
        validate = "on";
        problems = {
          shortenToSingleLine = false;
        };
        experimental = { };
        rulesCustomizations = [ ];

        codeActionsOnSave = {
          mode = "all";
          source.fixAll.eslint = true;
        };

        codeAction = {
          disableRuleComment = {
            enable = true;
            location = "separateLine";
          };
          showDocumentation = {
            enable = false;
          };
        };
      };
    };

    language = [
      ({ name = "tsx"; } // typescript)
      ({ name = "typescript"; } // typescript)
      ({ name = "jsx"; } // typescript)
      ({ name = "javascript"; } // typescript)
    ];
  };
}
