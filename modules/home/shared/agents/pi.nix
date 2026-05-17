{ lib, pkgs, ... }:
let
  inherit (lib) getExe escapeShellArg;
  inherit (builtins) concatStringsSep readFile;

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
    ];
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

}
