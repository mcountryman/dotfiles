{ pkgs, config, ... }:
let
  inherit (config.lib.file) mkOutOfStoreSymlink;

  root = "${config.home.homeDirectory}/Development/dotfiles";
  symlink = name: mkOutOfStoreSymlink "${root}/${name}";
in
{
  home.packages = with pkgs; [
    llm-agents.claude-code
  ];

  home.file.".claude" = {
    source = symlink "hosts/foldy-arm/users/marvin/claude";
    recursive = true;
  };
}
