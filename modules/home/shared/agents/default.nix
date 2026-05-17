{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) getExe escapeShellArg;
  inherit (builtins) concatStringsSep readFile;
  inherit (config.lib.file) mkOutOfStoreSymlink;

  self = "${config.home.homeDirectory}/Projects/dotfiles/modules/home/shared/agents";
  home = config.home.homeDirectory;
  mkPiBin =
    name: rules: promptFile:
    with pkgs;
    writeShellScriptBin name ''
      export PI_NONO_PROFILE="${name}"
      export NIX_SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"

      ${getExe nono} run \
        --allow-cwd  \
        --profile pi-readonly \
        ${concatStringsSep " " rules} \
        -- ${getExe llm-agents.pi} --append-system-prompt ${escapeShellArg (readFile promptFile)} "$@"
    '';
in
{
  home = {
    packages = with pkgs; [
      pnpm
      nono
      nodejs
      jq # Used by pi-notify systemd service

      (mkPiBin "pi" [
        "--allow $PWD"
        "--read /nix/store"
        "--allow ~/.cache/nix"
        # "--allow /nix/var/nix/daemon-socket" # Linux
        # "--allow /var/run/nix-daemon.socket" # Darwin
      ] ./pi/subagents/AGENT.md)

      (mkPiBin "pi-readonly" [ ] ./pi/subagents/AGENT_READONLY.md)
      (mkPiBin "pi-plan" [ "--allow $PWD/.agents/plans" ] ./pi/subagents/AGENT_PLAN.md)

      (writeShellScriptBin "claude" ''
        export CLAUDE_CONFIG_DIR="${home}/.config/claude";
        export NIX_SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"

        ${getExe nono} run --allow-cwd --profile claude -- ${getExe llm-agents.claude-code} "$@"
      '')
    ];

    file = {
      ".agents".source = mkOutOfStoreSymlink "${self}/agents";

      ".pi".source = mkOutOfStoreSymlink "${self}/pi";
      ".config/claude".source = mkOutOfStoreSymlink "${self}/claude";
    };
  };

  xdg.configFile = {
    "nono/profiles/pi-readonly.json".text =
      let
        inherit (lib) splitString;
        inherit (builtins) toJSON filter readFile;

        rootPaths = with pkgs; [
          # self
          llm-agents.pi

          # ssl
          cacert

          # misc
          which
          fd
          bat
          ripgrep

          # dev
          git

          # dev/js
          pnpm
          biome
          nodejs

          # dev/rust
          clippy
          rustfmt
        ];

        closure = pkgs.closureInfo { inherit rootPaths; };
        storePaths = filter (s: s != "") (splitString "\n" (readFile "${closure}/store-paths"));
      in

      toJSON {
        meta.name = "pi-readonly";

        filesystem = {
          # pi won't load model configuration without it.. :sigh:
          allow = [ "$HOME/.pi" ];

          read = storePaths ++ [
            # dotfiles
            "$HOME/Projects/dotfiles"
            # config
            "$HOME/.config/git"
            # tmp
            "/tmp"
            # agents
            "$HOME/.pi"
            "$HOME/.agents"
            "$HOME/.config/claude"
            # nodejs
            "$HOME/.npm"
            "$HOME/.cache/pnpm"
          ];
        };
      };
  };

  systemd.user = lib.optionalAttrs pkgs.stdenv.isLinux {
    paths.pi-notify = {
      Unit.Description = "Watch pi notification file";
      Path = {
        PathChanged = "${home}/.pi/notify";
        Unit = "pi-notify.service";
      };
      Install.WantedBy = [ "default.target" ];
    };

    services.pi-notify = {
      Unit.Description = "Forward pi notifications to macOS";
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
      Install.WantedBy = [ "default.target" ];
    };
  };
}
