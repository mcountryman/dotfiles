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
  home.sessionVariables = {
    CLAUDE_CONFIG_DIR = "${home}/.config/claude";
  };

  home.packages = with pkgs; [
    pnpm
    nono
    nodejs

    (writeShellScriptBin "pi" ''
      export PI_CODING_AGENT_DIR="${home}/.config/pi"

      ${getExe nono} run \
        --allow-cwd \
        --allow /tmp \
        --allow "${home}/.agents" \
        --allow "${home}/.config/pi" \
        --read /nix \
        --read "${home}/.cache/pnpm" \
        -- ${getExe llm-agents.pi}
    '')

    (writeShellScriptBin "claude" ''
      export CLAUDE_CONFIG_DIR="${home}/.config/claude";

      ${getExe nono} run \
        --allow-cwd \
        --allow /tmp \
        --allow "${home}/.agents" \
        --allow "${home}/.config/pi" \
        --read /nix \
        --read "${home}/.cache/pnpm" \
        --profile claude-code \
        -- ${getExe llm-agents.claude-code}
    '')
  ];

  home.file = {
    ".agents".source = mkOutOfStoreSymlink "${self}/agents";

    ".config/pi".source = mkOutOfStoreSymlink "${self}/pi";
    ".config/claude".source = mkOutOfStoreSymlink "${self}/claude";
  };
}
