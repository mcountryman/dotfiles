{
  lib,
  pkgs,
  config,
  ...
}:
let
  home = config.home.homeDirectory;
in
{
  systemd.user = lib.optionalAttrs pkgs.stdenv.isLinux {
    paths.pi-notify = {
      Unit.Description = "Watch pi notification file";
      Install.WantedBy = [ "default.target" ];
      Path = {
        PathChanged = "${home}/.pi/notify";
        Unit = "pi-notify.service";
      };
    };

    services.pi-notify = {
      Unit.Description = "Forward pi notifications to macOS";
      Install.WantedBy = [ "default.target" ];
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.writeShellScript "pi-notify-forward" ''
          NOTIFY_FILE="${home}/.pi/notify"

          # Skip if file doesn't exist or is empty
          [ ! -f "$NOTIFY_FILE" ] && exit 0
          [ ! -s "$NOTIFY_FILE" ] && exit 0

          # Read all lines, then truncate
          while IFS= read -r line; do
            [ -z "$line" ] && continue

            # Parse JSON and build osascript command using jq for safe escaping
            osascript_cmd=$(echo "$line" | ${pkgs.jq}/bin/jq -r '"display notification \"\(.message // "Done")\" with title \"\(.title // "Pi")\" subtitle \"\(.subtitle // "")\""')

            # Send via OrbStack mac CLI
            ${pkgs.lib.getExe' pkgs.coreutils "env"} PATH="/opt/orbstack-guest/bin:$PATH" mac run osascript -e "$osascript_cmd"
          done < "$NOTIFY_FILE"

          # Truncate the file after processing
          : > "$NOTIFY_FILE"
        ''}";
      };
    };
  };
}
