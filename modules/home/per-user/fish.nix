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
}
