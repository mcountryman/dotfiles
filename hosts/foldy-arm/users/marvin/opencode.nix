{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) getExe;
  inherit (config.lib.file) mkOutOfStoreSymlink;

  root = "${config.home.homeDirectory}/Development/dotfiles";
  symlink = name: mkOutOfStoreSymlink "${root}/${name}";
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

  home.file.".config/opencode" = {
    source = symlink "hosts/foldy-arm/users/marvin/opencode";
    recursive = true;
  };

  home.file.".agents" = {
    source = symlink "hosts/foldy-arm/users/marvin/agents";
    recursive = true;
  };
}
