{ lib, pkgs, ... }:
{
  programs.helix.languages.language-server.spellcheck = {
    command = "${lib.getExe pkgs.codebook}";
    args = [ "serve" ];
  };
}
