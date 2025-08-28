{
  lib,
  pkgs,
  config,
  ...
}:

{
  sops.secrets."openrouter".sopsFile = ./secrets.yaml;

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "goose" ''
      OPENROUTER_API_KEY='$(cat ${config.sops.secrets."openrouter".path})' \
        ${lib.getExe pkgs.goose-cli} $@
    '')
  ];
}
