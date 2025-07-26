{
  lib,
  pkgs,
  config,
  ...
}:
{
  stylix.targets.waybar.enable = true;

  wayland.windowManager.hyprland = {
    settings = {
      exec-once = [ "${lib.getExe pkgs.waybar}" ];
    };
  };

  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        height = 54;
        modules-left = [
          "hyprland/workspaces"
        ];
        modules-center = [ "hyprland/window" ];
        modules-right = [
          "tray"
          "pulseaudio"
          "network"
          "clock"
          "battery"
        ];

        tray = {
          spacing = 10;
          icon-size = 24;
        };

        "hyprland/workspaces" = {
          persistent-workspaces."*" = 9;
        };

        battery = {
          max-length = 25;
          interval = 60;
          states = {
            warning = 30;
            critical = 15;
          };

          format = "{icon}  {capacity}%";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];
        };

        pulseaudio = {
          format = "{icon}  {volume}%";
          format-muted = "";
          format-icons = {
            "alsa_output.pci-0000_00_1f.3.analog-stereo" = "";
            "alsa_output.pci-0000_00_1f.3.analog-stereo-muted" = "";
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            phone-muted = "";
            portable = "";
            car = "";
            default = [
              ""
              ""
            ];
          };

          scroll-step = 1;
          on-click = "GDK_DISABLE=vulkan ${lib.getExe pkgs.pavucontrol}";
        };

        network = {
          interface = "wlan0";
          format = "{ifname}";
          format-wifi = "  {essid} ({signalStrength}%)";
          format-ethernet = "󰊗  {ipaddr}/{cidr}";
          format-disconnected = ""; # An empty format will hide the module.
          tooltip-format = "󰊗  {{ifname} via {gwaddr} 󰊗";
          tooltip-format-wifi = "  {essid} ({signalStrength}%)";
          tooltip-format-ethernet = "   {ifname}";
          tooltip-format-disconnected = "Disconnected";
          max-length = 50;
        };

        clock = {
          # format = "  {:%H:%M} ";
          format = "  {:%a, %F %R}";
          timezones = [ "America/New_York" ];
          tooltip = false;
        };
      };
    };

    style =
      with config.lib.stylix.colors;
      lib.mkForce ''
        * {
          font-family: IosevkaTerm Nerd Font;
          font-size: 16px;

          border: none;
          border-radius: 0;
          margin: 0;
          padding: 0;
          min-height: 0;
          color: #${base04};
          background: transparent;
          background-color: transparent;
        }

        #clock,
        #window,
        #network,
        #battery,
        #workspaces,
        #pulseaudio {
          border: 1px solid #${base03};
          padding: 5px 10px;
          background: #${base00};

          margin-top: 5px;
        }

        .modules-right {
          margin-right: 20px;
        }

        .modules-right .module {
          margin-left: 10px;
        }

        .modules-left {
          margin-left: 20px;
        }

        .modules-left .module {
          margin-right: 10px;
        }

        #workspaces {
          padding: 0;
        }

        #workspaces button {
          padding: 0px 10px;
        }

        #workspaces button:hover {
          background: #${base02};
        }

        #workspaces button.active {
          box-shadow: inset 0px -3px #${base0D};
        }
         
        #workspaces button.urgent {
          box-shadow: inset 0px -3px #${base09};
        }

        tooltip {         
          color: #${base05};
          border: 1px solid #${base0D};
          background: #${base00};
        }
      '';
  };
}
