{
  me,
  inputs,
  ...
}:
let
  inherit (inputs) homebrew-core homebrew-cask homebrew-bundle;
in
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

    user = me;
    taps = {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
      "homebrew/homebrew-bundle" = homebrew-bundle;
    };
  };
}
