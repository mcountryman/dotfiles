{ config, ... }:
{
  homebrew = {
    enable = true;
    # Cleanup unused packages on rebuild
    onActivation.cleanup = "zap";
  };

  nix-homebrew = {
    enable = true;
    enableRosetta = false;
    mutableTaps = false;

    user = config.system.primaryUser;
  };
}
