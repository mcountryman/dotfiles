{ lib, pkgs, ... }:
let
  jj-starship = lib.getExe pkgs.jj-starship;
in
{
  stylix.targets.starship.enable = true;

  programs.starship = {
    enable = true;
    settings = {
      format = builtins.concatStringsSep "" [
        " "
        "$directory"
        # "$hostname"
        # "$localip"
        # "$git"
        "$custom"
        "$cmd_duration"
        "$line_break"
        "$jobs"
        "$battery"
        "$time"
        "$status"
        "$container"
        "$netns"
        "$os"
        "$shell"
        "$character"
      ];

      character = {
        error_symbol = " [>](bold red)";
        success_symbol = " [>](bold green)";
      };

      container.disabled = true;

      custom.jj = {
        when = "${jj-starship} detect";
        shell = [ "${jj-starship}" ];
        format = "$output ";
      };
      # custom.jj = {
      #   command = "prompt";
      #   format = "$output";
      #   ignore_timeout = true;
      #   shell = [
      #     "starship-jj"
      #     "--ignore-working-copy"
      #     "starship"
      #   ];
      #   use_stdin = false;
      #   when = true;
      # };
    };
  };
}
