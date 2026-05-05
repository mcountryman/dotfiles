{ pkgs, ... }:
{
  home.packages = with pkgs; [
    llm-agents.claude-code
  ];

  programs.fish.shellInit = ''
    set -gx CLAUDE_CODE_DISABLE_MOUSE 1
    set -gx CLAUDE_CODE_TMUX_TRUECOLOR 1
  '';
}
