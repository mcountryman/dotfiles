{ lib, pkgs, ... }:
let
  inherit (lib) getExe;
in
{
  home = {
    packages = with pkgs; [
      (writeShellScriptBin "claude" ''
        export NIX_SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"

        ${getExe nono} run \
          --allow-cwd \
          --allow /tmp \
          --profile claude-code \
          -- ${getExe llm-agents.claude-code} "$@"
      '')
    ];
  };
}
