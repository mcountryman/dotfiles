# keychain - auto-magic ssh key management
{
  programs.keychain = {
    enable = true;
    enableFishIntegration = true;

    keys = [ "id_ed25519" ];
  };
}
