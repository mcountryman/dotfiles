{
  me,
  pkgs,
  ...
}:
{
  # Enable alternative shell support in nix-darwin.
  programs.fish.enable = true;
  # Set the user's login shell
  users.users.${me}.shell = "${pkgs.fish}/bin/fish";

  home-manager.users.${me} = {
    programs.fish = {
      enable = true;

      shellAliases = {
        "ls" = "exa";
        "la" = "exa -la";
      };

      interactiveShellInit = ''
        if status is-interactive
          if type -q zellij
            # Update the zellij tab name with the current process name or pwd.
            function zellij_tab_name_update_pre --on-event fish_preexec
              if set -q ZELLIJ
                set -l cmd_line (string split " " -- $argv)
                set -l process_name $cmd_line[1]
                if test -n "$process_name" -a "$process_name" != "cd"
                  command nohup zellij action rename-tab $process_name >/dev/null 2>&1
                end
              end
            end

            function zellij_tab_name_update_post --on-event fish_postexec
              if set -q ZELLIJ
                set -l cmd_line (string split " " -- $argv)
                set -l process_name $cmd_line[1]
                if test "$process_name" = "cd"
                  command nohup zellij action rename-tab (prompt_pwd) >/dev/null 2>&1
                end
              end
            end
          end
        end

        function fish_greeting
            echo '                  '(set_color F00)'___
           ___======____='(set_color FF7F00)'-'(set_color FF0)'-'(set_color FF7F00)'-='(set_color F00)')
         /T            \_'(set_color FF0)'--='(set_color FF7F00)'=='(set_color F00)')    '(set_color red)(whoami)'@'(hostname)'
         [ \ '(set_color FF7F00)'('(set_color FF0)'0'(set_color FF7F00)')   '(set_color F00)'\~    \_'(set_color FF0)'-='(set_color FF7F00)'='(set_color F00)')'(set_color yellow)'    Uptime: '(set_color white)(uptime | sed 's/.*up \([^,]*\), .*/\1/')(set_color red)'
          \      / )J'(set_color FF7F00)'~~    \\'(set_color FF0)'-='(set_color F00)')    IP Address: '(set_color white)(ipconfig getifaddr en0)(set_color red)'
           \\\\___/  )JJ'(set_color FF7F00)'~'(set_color FF0)'~~   '(set_color F00)'\)     '(set_color yellow)'Version: '(set_color white)(echo $FISH_VERSION)(set_color red)'
            \_____/JJJ'(set_color FF7F00)'~~'(set_color FF0)'~~    '(set_color F00)'\\
            '(set_color FF7F00)'/ '(set_color FF0)'\  '(set_color FF0)', \\'(set_color F00)'J'(set_color FF7F00)'~~~'(set_color FF0)'~~     '(set_color FF7F00)'\\
           (-'(set_color FF0)'\)'(set_color F00)'\='(set_color FF7F00)'|'(set_color FF0)'\\\\\\'(set_color FF7F00)'~~'(set_color FF0)'~~       '(set_color FF7F00)'L_'(set_color FF0)'_
           '(set_color FF7F00)'('(set_color F00)'\\'(set_color FF7F00)'\\)  ('(set_color FF0)'\\'(set_color FF7F00)'\\\)'(set_color F00)'_           '(set_color FF0)'\=='(set_color FF7F00)'__
            '(set_color F00)'\V    '(set_color FF7F00)'\\\\'(set_color F00)'\) =='(set_color FF7F00)'=_____   '(set_color FF0)'\\\\\\\\'(set_color FF7F00)'\\\\
                   '(set_color F00)'\V)     \_) '(set_color FF7F00)'\\\\'(set_color FF0)'\\\\JJ\\'(set_color FF7F00)'J\)
                               '(set_color F00)'/'(set_color FF7F00)'J'(set_color FF0)'\\'(set_color FF7F00)'J'(set_color F00)'T\\'(set_color FF7F00)'JJJ'(set_color F00)'J)
                               (J'(set_color FF7F00)'JJ'(set_color F00)'| \UUU)
                                (UU)'(set_color normal)
        end

        ssh-add --apple-load-keychain 2> /dev/null
        ${pkgs.starship}/bin/starship init fish | source
      '';

      plugins = [ ];
    };

    # fish : prompt
    programs.starship = {
      enable = true;
      settings = {
        format = " $all";
        character = {
          error_symbol = " [>](bold red)";
          success_symbol = " [>](bold green)";
        };
      };
    };

    # fish : cd
    programs.zoxide = {
      enable = true;
      enableFishIntegration = true;
      options = [ "--cmd cd" ];
    };

    # fish : la
    programs.eza = {
      enable = true;
      enableFishIntegration = true;
    };

    programs.yazi = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
