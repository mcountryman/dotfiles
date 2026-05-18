{ lib, pkgs, ... }:
let
  inherit (lib) getExe;
in
{
  home = {
    packages = with pkgs; [
      (writeShellScriptBin "opencode" ''
        export NIX_SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"

        git_common_dir="$(git rev-parse --git-common-dir)"

        ${getExe nono} run \
          --allow "$PWD" \
          --allow "''${git_common_dir:-/tmp}" \
          --allow ~/.cache/nix \
          --allow /tmp \
          --read /nix/store \
          --profile opencode \
          -- ${getExe llm-agents.opencode} "$@"
      '')
    ];
  };

  xdg.configFile = {
    "opencode/opencode.json".source = pkgs.writeText "settings.json" ''
      {
        "$schema": "https://opencode.ai/config.json",
        "enabled_providers": ["ollama", "openrouter", "anthropic"],
        "provider": {
          "ollama": {
            "npm": "@ai-sdk/openai-compatible",
            "name": "Ollama (local)",
            "options": {
              "baseURL": "http://host.orb.internal:11434/v1"
            },
            "models": {
              "gemma4:latest" : {
                "name": "gemma4:latest",
                "tools": true
              }
            }
          }
        }
      }
    '';
  };

  systemd.user.tmpfiles.rules = [
    "d %h/.cache/opencode       - - - - -"
    "d %h/.config/opencode      - - - - -"
    "d %h/.local/share/opentui  - - - - -"
    "d %h/.local/share/opencode - - - - -"
    "d %h/.local/state/opencode - - - - -"
  ];
}
