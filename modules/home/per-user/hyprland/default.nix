{ pkgs, ... }:
{
  imports = [
    ./idle.nix
    ./lock.nix
    ./binds.nix
    ./notify.nix
    ./waybar.nix
    ./windows.nix
    ./launcher.nix
  ];

  stylix.targets.gtk.enable = true;
  stylix.targets.hyprland.enable = true;
  stylix.targets.hyprpaper.enable = true;

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 16;
  };

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      env = [
        # Hint Electron apps to use Wayland
        "NIXOS_OZONE_WL,1"
        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_TYPE,wayland"
        "XDG_SESSION_DESKTOP,Hyprland"
        "QT_QPA_PLATFORM,wayland"
        "XDG_SCREENSHOTS_DIR,$HOME/screens"
      ];

      monitor = "eDP-1, 3456x2160@60, 0x0, 1.5";
      general = {
        allow_tearing = true;

        gaps_out = "0,20,20,20";
      };

      input = {
        sensitivity = 0.0;
        accel_profile = "adaptive";

        touchpad = {
          tap-to-click = false;
          clickfinger_behavior = true;
        };
      };

      gestures = {
        workspace_swipe = true;
      };

      animation = [
        "fade, 1, 2, default"
        "border, 1, 2, default"
        "windows, 1, 2, default"
      ];

      misc = {
        disable_hyprland_logo = true;

      };
    };
  };

  services.hyprpaper.enable = true;
}
