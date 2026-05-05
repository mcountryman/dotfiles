{ lib, pkgs, ... }:
let
  inherit (lib) getExe;
in
{
  home.packages = with pkgs; [
    (writeShellScriptBin "opencode" ''
      set -eu

      eval "$(ssh-agent -s)" >/dev/null
      ssh-add ~/.ssh/agent/deploy >/dev/null
      trap "ssh-agent -k 2>/dev/null" EXIT

      ${getExe llm-agents.opencode} "$@"
    '')
  ];
}
