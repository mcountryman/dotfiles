{ config, ... }:
let
  inherit (config.lib.file) mkOutOfStoreSymlink;

  self = "${config.home.homeDirectory}/Projects/dotfiles/modules/home/shared/agents";
in
{
  home.file = {
    ".agents".source = mkOutOfStoreSymlink "${self}/agents";

    ".pi".source = mkOutOfStoreSymlink "${self}/pi";
    ".config/claude".source = mkOutOfStoreSymlink "${self}/claude";
  };
}
