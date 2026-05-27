{ lib, pkgs, ... }:
let
  inherit (lib) getExe;
  inherit (builtins) toJSON;
in
{
  home = {
    packages = with pkgs; [
      pnpm
      nono
      nodejs

      (writeShellScriptBin "pi" ''
        export NIX_SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"

        git_common_dir="$(git rev-parse --git-common-dir)"

        ${getExe nono} run \
          --allow "$PWD" \
          --allow "''${git_common_dir:-/tmp}" \
          --profile pi \
          -- ${getExe llm-agents.pi} "$@"
      '')

      (writeShellScriptBin "pi-no-sandbox" ''
        ${getExe llm-agents.pi} "$@"
      '')
    ];
  };

  xdg.configFile = {
    "nono/profiles/pi.json".text = toJSON {
      meta.name = "pi";

      filesystem = {
        allow = [
          # pi
          "$HOME/.pi"
          # tmp
          "/tmp"
          # nix
          "$HOME/.cache/nix"
          # rust
          "$HOME/.cargo"
          # nodejs
          "$HOME/.npm"
          "$HOME/.cache/pnpm"
          "$HOME/.local/share/pnpm"
        ];

        read = [
          # nix
          "/nix/store"
          # config
          "$HOME/.config/git"
          # agents
          "$HOME/.agents"
          "$HOME/.config/claude"
          # dotfiles
          "$HOME/Projects/dotfiles"
        ];
      };
    };
  };

}
