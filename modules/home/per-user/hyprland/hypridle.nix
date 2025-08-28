{ lib, pkgs, ... }:
let
  lock = lib.getExe pkgs.hyprlock;
in
{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof ${lock} || ${lock}";

        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        # Dim backlight
        {
          timeout = 150; # 2.5m
          on-timeout = "${lib.getExe pkgs.brightnessctl} -c backlight -s set 0";
          on-resume = "${lib.getExe pkgs.brightnessctl} -c backlight -r";
        }

        {
          timeout = 400; # 5m
          on-timeout = "loginctl lock-session";
        }
      ];
    };
  };
}
