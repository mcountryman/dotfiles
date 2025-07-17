# fish - an alternate shell to bash with batteries included
#
# Configuration includes binaries/integrations I use on a daily.

{ pkgs, ... }:
{
  stylix.targets.fish.enable = true;

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

      ${pkgs.starship}/bin/starship init fish | source
    '';

    plugins = [ ];
  };

  stylix.targets.starship.enable = true;

  # Straight forward prompt giving me most of the information I want to see
  #
  # TODO: Consider trimming down the modules.  I probably don't need all of what
  # is shown by default.
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

  # Fancy `cd` with more better shortcuts
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    options = [ "--cmd cd" ];
  };

  # Fancy `ls` with colors++
  programs.eza = {
    enable = true;
    enableFishIntegration = true;
  };

  # Automatic environment setup when `cd`-ing into a dir
  programs.direnv = {
    enable = true;

    nix-direnv.enable = true;
  };

  stylix.targets.yazi.enable = true;

  # File management
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
  };
}
