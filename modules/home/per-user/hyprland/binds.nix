{ lib, pkgs, ... }:
{
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";

    bind = [
      "$mod, Space, exec, ${lib.getExe pkgs.anyrun}"
      "$mod, Return, exec, ${lib.getExe pkgs.wezterm}"
      "$mod, Backspace, exec, ${lib.getExe pkgs.hyprlock}"

      "$mod, C, exec, copyq copy"
      "$mod, V, exec, wl-paste"

      "$mod, Q, closewindow, activewindow"
      "$mod SHIFT, F, fullscreen, 1"

      "$mod, H, movefocus, l"
      "$mod, J, movefocus, d"
      "$mod, K, movefocus, u"
      "$mod, L, movefocus, r"

      "$mod SHIFT, H, movewindow, l"
      "$mod SHIFT, J, movewindow, d"
      "$mod SHIFT, K, movewindow, u"
      "$mod SHIFT, L, movewindow, r"

      "$mod, 1, workspace, 1"
      "$mod, 2, workspace, 2"
      "$mod, 3, workspace, 3"
      "$mod, 4, workspace, 4"
      "$mod, 5, workspace, 5"
      "$mod, 6, workspace, 6"
      "$mod, 7, workspace, 7"
      "$mod, 8, workspace, 8"
      "$mod, 9, workspace, 9"
      "$mod, 0, workspace, 0"
      "$mod, left, workspace, -1"
      "$mod, right, workspace, +1"

      "$mod SHIFT, 1, movetoworkspace, 1"
      "$mod SHIFT, 2, movetoworkspace, 2"
      "$mod SHIFT, 3, movetoworkspace, 3"
      "$mod SHIFT, 4, movetoworkspace, 4"
      "$mod SHIFT, 5, movetoworkspace, 5"
      "$mod SHIFT, 6, movetoworkspace, 6"
      "$mod SHIFT, 7, movetoworkspace, 7"
      "$mod SHIFT, 8, movetoworkspace, 8"
      "$mod SHIFT, 9, movetoworkspace, 9"
      "$mod SHIFT, 0, movetoworkspace, 0"
      "$mod SHIFT, left, movetoworkspace, -1"
      "$mod SHIFT, right, movetoworkspace, +1"

      ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_SINK@ toggle"
      ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
      ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"

      ", XF86AudioPlay, exec, ${lib.getExe pkgs.playerctl} play-pause"
      ", XF86AudioPrev, exec, ${lib.getExe pkgs.playerctl} previous"
      ", XF86AudioNext, exec, ${lib.getExe pkgs.playerctl} next"

      ", XF86MonBrightnessUp, exec, ${lib.getExe pkgs.brightnessctl} -c backlight set 10%+"
      ", XF86MonBrightnessDown, exec, ${lib.getExe pkgs.brightnessctl} -c backlight set 10%-"
    ];
  };
}
