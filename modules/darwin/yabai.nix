# yabai window manager setup
#
# I really need to dig into rules a bit more.  The ignore rules I have kinda 
# work although somethimes things just break.  Steam for example is completly
# unmanagable although I suspect this is a Steam issue.

{ lib, pkgs, ... }:
let
  jq = lib.getExe pkgs.jq;
  yabai = lib.getExe pkgs.yabai;

  # Keep the magic pixies in my lithium brick for a bit longer
  off = "0xff000000";

  # Stolen from the helix ayu_theme
  background = "0xff0f1419";
  foreground = "0xffbfbdb6";

  black = "0xff131721";
  blue = "0xff59c2ff";
  dark_gray = "0xff2d3640";
  cyan = "0xff73b8ff";
  gray = "0xff5c6773";
  green = "0xffaad94c";
  magenta = "0xffd2a6ff";
  orange = "0xffff8f40";
  red = "0xfff07178";
  yellow = "0xffe6b450";

  scripts = {
    mode-default = pkgs.writeScriptBin "run" ''
      spacebar -m config spaces on
      spacebar -m config left_shell off
    '';
    mode-resize = pkgs.writeScriptBin "run" ''
      spacebar -m config left_shell_command "echo resize"
      spacebar -m config left_shell_icon_color "${red}"
      spacebar -m config left_shell_icon "󰊕"

      spacebar -m config spaces off
      spacebar -m config left_shell on
    '';
  };
in
{
  services.yabai = {
    enable = true;
    enableScriptingAddition = true;

    config = {
      # Mouse
      # focus_follows_mouse = "autoraise";

      # Layout
      layout = "bsp";
      top_padding = 8;
      left_padding = 8;
      right_padding = 8;
      bottom_padding = 8;
      window_gap = 8;
      # menubar_opacity = 0.0;

      # Style
      window_shadow = "float";
      # window_opacity = "on";
      # normal_window_opacity  = 0.9;
      # active_window_opacity  = 1.0;
    };

    extraConfig = ''
      # Automations
      yabai -m rule --add label="Bitwarden" app="^Bitwarden$" manage=off
      yabai -m rule --add label="Calculator" app="^Calculator$" manage=off
      yabai -m rule --add label="System Settings" app="^System Settings$" manage=off
      yabai -m rule --add label="Activity Monitor" app="^System Settings$" manage=off
      yabai -m rule --add app="^Steam$" manage=off

      # Spaces
      yabai -m space 1 -label 1
      yabai -m space 2 --label 2
      yabai -m space 3 --label 3
      yabai -m space 4 --label 4
      yabai -m space 5 --label 5
      yabai -m space 6 --label 6
      yabai -m space 7 --label 7
      yabai -m space 8 --label 8
      yabai -m space 9 --label 9
      yabai -m space 10 --label 10

      # Scripting additions
      yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"
      yabai -m signal --add event=dock_did_restart action="skhd -r"

      # Minimized windows to space 10
      yabai -m signal --add event=window_minimized action="yabai -m window \$YABAI_WINDOW_ID --space 10; yabai -m window --deminimize \$YABAI_WINDOW_ID"

      sudo yabai --load-sa
    '';
  };

  services.skhd = {
    enable = true;
    skhdConfig = ''
      cmd - return : ${pkgs.alacritty}/bin/alacritty

      cmd - h : yabai -m window --focus west
      cmd - j : yabai -m window --focus south
      cmd - k : yabai -m window --focus north
      cmd - l : yabai -m window --focus east

      cmd + shift - h : yabai -m window --warp west
      cmd + shift - j : yabai -m window --warp south
      cmd + shift - k : yabai -m window --warp north
      cmd + shift - l : yabai -m window --warp east

      cmd - 1 : yabai -m space --focus 1
      cmd - 2 : yabai -m space --focus 2
      cmd - 3 : yabai -m space --focus 3
      cmd - 4 : yabai -m space --focus 4
      cmd - 5 : yabai -m space --focus 5
      cmd - 6 : yabai -m space --focus 6
      cmd - 7 : yabai -m space --focus 7
      cmd - 8 : yabai -m space --focus 8
      cmd - 9 : yabai -m space --focus 9
      cmd - 0 : yabai -m space --focus 10

      cmd + shift - 1 : yabai -m window --space 1
      cmd + shift - 2 : yabai -m window --space 2
      cmd + shift - 3 : yabai -m window --space 3
      cmd + shift - 4 : yabai -m window --space 4
      cmd + shift - 5 : yabai -m window --space 5
      cmd + shift - 6 : yabai -m window --space 6
      cmd + shift - 7 : yabai -m window --space 7
      cmd + shift - 8 : yabai -m window --space 8
      cmd + shift - 9 : yabai -m window --space 9
      cmd + shift - 0 : yabai -m window --space 10

      cmd + shift - f : yabai -m window --toggle zoom-fullscreen
      cmd + shift - return : yabai -m window --toggle native-fullscreen

      cmd - m : yabai -m window --toggle min-scratch

      :: default : ${scripts.mode-default}/bin/run

      :: resize : ${scripts.mode-resize}/bin/run

      cmd + shift - r ; resize

      resize < h : yabai -m window --resize left:-20:0 ; yabai -m window --resize right:-20:0
      resize < j : yabai -m window --resize top:20:0 ; yabai -m window --resize bottom:0:20
      resize < k : yabai -m window --resize top:0:-20 ; yabai -m window --resize bottom:0:-20
      resize < l : yabai -m window --resize left:20:0 ; yabai -m window --resize right:20:0

      resize < escape ; default
    '';
  };

  services.spacebar = {
    enable = false;
    package = pkgs.spacebar;
    config = {
      display = "main";

      height = 38;
      position = "top";
      spacing_left = 20;
      spacing_right = 30;

      # icon_font = ''"ProggyClean CE Nerd Font:Regular:18.0"'';
      # text_font = ''"ProggyClean CE Nerd Font:Regular:18.0"'';
      icon_font = ''"IosevkaTerm Nerd Font:Regular:14.0"'';
      text_font = ''"IosevkaTerm Nerd Font:Regular:14.0"'';

      background_color = "${off}";
      foreground_color = "${foreground}";

      title = "off";

      spaces = "on";
      space_icon_strip = "I II III IV V VI VII VIII IX 󰩹";
      space_icon_color = "${green}";
      space_icon_color_secondary = "${orange}";
      space_icon_color_tertiary = "${orange}";

      clock = "on";
      clock_format = ''" %a %F %I:%M %p"'';
      clock_icon = "󰅐";
      clock_icon_color = "${magenta}";

      power = "on";
      power_icon_strip = " ";
      power_icon_color = "${yellow}";
      battery_icon_color = "${red}";

      dnd = "on";
      dnd_icon = "";
      dnd_icon_color = "${foreground}";
    };
  };

  services.jankyborders = {
    enable = true;
    width = 1.0;
    hidpi = true;
    order = "above";
    active_color = "${green}";
    inactive_color = "0x00000000";
  };

  # system.activationScripts.postActivation.text = ''
  #   sudo -i -u "${me}" bash << EOF
  #     # Create a max of 10 spaces
  #     spaces=$(${yabai} -m query --spaces | ${jq} length)
  #
  #     for _i in $(seq "\$spaces" 9)
  #     do
  #       ${yabai} -m space --create
  #     done
  #   EOF
  # '';
}
