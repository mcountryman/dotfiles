{ pkgs, config, ... }:
let
  inherit (pkgs.lib) getExe;
  inherit (config.lib.file) mkOutOfStoreSymlink;

  userDir = "${config.home.homeDirectory}/Development/dotfiles/hosts/foldy-arm/users/marvin";
  mkAgentWrapper =
    name: exe:
    pkgs.writeShellScriptBin name ''
      unset SSH_AUTH_SOCK
      unset SSH_AGENT_PID
      export SSH_CONFIG_FILE=~/.ssh/agents/config
      export CLAUDE_CODE_DISABLE_MOUSE=1
      export CLAUDE_CODE_TMUX_TRUECOLOR=1

      ssh-agent sh -c 'ssh-add ~/.ssh/agents/id_agents && ${exe} "$@"' -- "$@"
    '';
in
{
  home.file = {
    ".agents".source = mkOutOfStoreSymlink "${userDir}/agents";
    ".claude".source = mkOutOfStoreSymlink "${userDir}/claude";
    ".config/opencode".source = mkOutOfStoreSymlink "${userDir}/opencode";
  };

  home.packages = with pkgs; [
    (mkAgentWrapper "claude" (getExe llm-agents.claude-code))
    (mkAgentWrapper "opencode" (getExe llm-agents.opencode))
  ];
}
