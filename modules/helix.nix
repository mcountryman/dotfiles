{ lib, pkgs, user, ... }:

let
  nix = {
    name = "nix";
    auto-format = true;
    formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
  };
  rust = {
    name = "rust";
    auto-format = true;
    indent = {
      tab-width = 2;
      unit = " ";
    };
  };
  toml = {
    name = "toml";
    auto-format = true;
    formatter = {
      command = "${pkgs.taplo}/bin/taplo";
      args = [ "taplo" "format" "-" ];
    };
  };
  hcl = {
    name = "hcl";
    auto-format = true;
    formatter = {
      command = "${pkgs.opentofu}/bin/tofu";
      args = [ "fmt" "-" ];
    };
  };
  typescript-language-server = name: {
    name = "${name}";
    language-servers = [ "typescript-language-server" "eslint" ];
    auto-format = true;
    formatter = {
      command = "prettier";
      args = [ "--parser" "typescript" ];
    };
  };
in {
  environment.systemPackages = [
    #
    pkgs.nodePackages.prettier
    pkgs.vscode-langservers-extracted
    pkgs.typescript-language-server
    pkgs.terraform-ls
    pkgs.bash-language-server
  ];

  home-manager.users.${user} = {
    programs.helix = {
      enable = true;
      settings = {
        theme = "ayu_dark";
        editor = {
          mouse = false;
          shell = [ "fish" "-c" ];
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
            left = [ "mode" "diagnostics" ];
            right = [ "selections" "position" ];
            center = [ "file-name" "file-modification-indicator" ];
          };
        };

        keys = {
          normal = {
            "esc" = [ "keep_primary_selection" "collapse_selection" ];
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
          nix
          hcl
          rust
          toml
          (typescript-language-server "tsx")
          (typescript-language-server "jsx")
          (typescript-language-server "typescript")
          (typescript-language-server "javascript")
        ];

        language-server.eslint = {
          args = [ "--stdio" ];
          command = "vscode-eslint-language-server";
          config = {
            run = "onType";
            quiet = false;
            format = { enable = true; };
            nodePath = "";
            validate = "on";
            problems = { shortenToSingleLine = false; };
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
              showDocumentation = { enable = false; };
            };
          };
        };
      };
    };
  };
}
