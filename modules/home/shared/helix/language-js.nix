{ pkgs, ... }:
let
  vscode-eslint = "${pkgs.vscode-langservers-extracted}/bin/vscode-eslint-language-server";

  mkTypescriptLangConf = name: {
    inherit name;

    auto-format = true;
    roots = [
      "biome.json"
      "biome.jsonc"
      "package.json"
    ];
    language-servers = [
      "biome"
      {
        name = "typescript-language-server";
        except-features = [ "format" ];
      }
    ];
  };
in
{
  home.packages = [
    pkgs.biome
    pkgs.typescript-language-server
    pkgs.vscode-langservers-extracted
  ];

  programs.helix.languages = {
    language = [
      (mkTypescriptLangConf "jsx")
      (mkTypescriptLangConf "tsx")
      (mkTypescriptLangConf "javascript")
      (mkTypescriptLangConf "typescript")
    ];

    language-server = {
      biome = {
        command = "biome";
        args = [ "lsp-proxy" ];
      };

      eslint = {
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
    };

  };
}
