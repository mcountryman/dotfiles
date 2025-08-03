# keychain - auto-magic ssh key management
{ config, ... }:
{
  programs.keychain = {
    enable = !config.dotfiles.yubi;
    enableFishIntegration = true;

    keys = [ "id_ed25519" ];
  };
}
