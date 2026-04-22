{ lib, pkgs, ... }:
let
  vscode-eslint = "${pkgs.vscode-langservers-extracted}/bin/vscode-eslint-language-server";

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
    pkgs.typescript-language-server
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
