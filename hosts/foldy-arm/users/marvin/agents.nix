{ config, ... }:
let
  inherit (config.lib.file) mkOutOfStoreSymlink;

  userDir = "${config.home.homeDirectory}/Development/dotfiles/hosts/foldy-arm/users/marvin";
in
{
  home.file = {
    ".agents".source = mkOutOfStoreSymlink "${userDir}/agents";
    ".claude".source = mkOutOfStoreSymlink "${userDir}/claude";
    ".config/opencode".source = mkOutOfStoreSymlink "${userDir}/opencode";
  };
}
