{
  lib,
  pkgs,
  user,
  config,
  ...
}:

let
  typescript-language-server = name: {
    name = "${name}";
    language-servers = [
      "typescript-language-server"
      "eslint"
    ];
    auto-format = true;
    formatter = {
      command = "prettier";
      args = [
        "--parser"
        "typescript"
      ];
    };
  };
in
{
  environment.systemPackages = [
    #
    pkgs.nodePackages.prettier
    pkgs.vscode-langservers-extracted
    pkgs.typescript-language-server
    pkgs.terraform-ls
    pkgs.bash-language-server
    pkgs.yaml-language-server
    pkgs.nil
    pkgs.nixd
    (pkgs.vale.withStyles (s: [
      s.google
    ]))
  ];

  home-manager.users.${user} = {
    programs.helix = {
      enable = true;
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
      languages = {
        language = [
          {
            name = "nix";
            auto-format = true;
            # formatter.command = lib.getExe pkgs.nixfmt-rfc-style;
            formatter.command = lib.getExe pkgs.alejandra;
          }
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
          {
            name = "toml";
            auto-format = true;
            formatter = {
              command = lib.getExe pkgs.taplo;
              args = [
                "taplo"
                "format"
                "-"
              ];
            };
          }
          {
            name = "hcl";
            auto-format = true;
            formatter = {
              command = lib.getExe pkgs.opentofu;
              args = [
                "fmt"
                "-"
              ];
            };
          }
          {
            name = "yaml";
            auto-format = true;
            formatter = {
              command = "prettier"; # NOTE: This should directly link to the prettier nix pkg but, fuggit
              args = [
                "--parser"
                "yaml"
              ];
            };
          }
          (typescript-language-server "tsx")
          (typescript-language-server "jsx")
          (typescript-language-server "typescript")
          (typescript-language-server "javascript")
        ];

        language-server.spellcheck = {
          command = lib.getExe pkgs.vale-ls;
        };

        language-server.eslint = {
          args = [ "--stdio" ];
          command = "vscode-eslint-language-server";
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
  };
}
