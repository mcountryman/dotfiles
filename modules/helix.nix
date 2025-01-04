{ pkgs, user, ... }:

{
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
          auto-format = true;
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
          {
            name = "nix";
            auto-format = true;
            formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
          }
          {
            name = "rust";
            indent = {
              tab-width = 2;
              unit = " ";
            };
          }
          {
            name = "toml";
            formatter = {
              command = "${pkgs.taplo}/bin/taplo";
              args = [ "taplo" "format" "-" ];
            };
          }
        ];
      };
    };
  };
}
