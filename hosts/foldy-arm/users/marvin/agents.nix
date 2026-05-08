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

    ".npmrc".text = ''
      prefix = ''${HOME}/.npm-packages
    '';
  };

  programs.fish.shellInit = ''
    fish_add_path $HOME/.npm-packages/bin
    fish_add_path $HOME/.npm-packages/lib/node_modules
  '';

  home.packages = with pkgs; [
    nodejs

    (mkAgentWrapper "pi" (getExe llm-agents.pi))
    (mkAgentWrapper "claude" (getExe llm-agents.claude-code))
    (mkAgentWrapper "opencode" (getExe llm-agents.opencode))
  ];
}
