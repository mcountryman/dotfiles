{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) getExe;
  inherit (config.lib.file) mkOutOfStoreSymlink;

  self = "${config.home.homeDirectory}/Projects/dotfiles/modules/home/shared/agents";
  home = config.home.homeDirectory;
in
{
  imports = [ ./profiles.nix ];

  home = {
    packages = with pkgs; [
      pnpm
      nono
      nodejs

      (writeShellScriptBin "pi" ''
        export PI_CODING_AGENT_DIR="${home}/.config/pi"
        export NIX_SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"

        ${getExe nono} run --allow-cwd --profile pi -- ${getExe llm-agents.pi} "$@"
      '')

      (writeShellScriptBin "pi-nix" ''
        export PI_CODING_AGENT_DIR="${home}/.config/pi"
        export NIX_SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"

        ${getExe nono} run --allow-cwd --profile pi-nix -- ${getExe llm-agents.pi} "$@"
      '')

      (writeShellScriptBin "claude" ''
        export CLAUDE_CONFIG_DIR="${home}/.config/claude";
        export NIX_SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"

        ${getExe nono} run --allow-cwd --profile claude -- ${getExe llm-agents.claude-code} "$@"
      '')
    ];

    file = {
      ".agents".source = mkOutOfStoreSymlink "${self}/agents";

      ".config/pi".source = mkOutOfStoreSymlink "${self}/pi";
      ".config/claude".source = mkOutOfStoreSymlink "${self}/claude";
    };
  };
}
