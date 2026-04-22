# keychain - auto-magic ssh key management (for hosts without YubiKey)
{
  programs.keychain = {
    enable = true;
    enableFishIntegration = true;
    keys = [ "id_ed25519" ];
  };
}
