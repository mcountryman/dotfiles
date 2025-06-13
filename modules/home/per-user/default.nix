{ user, ... }:
{
  # imports = [
  #   inputs.nur.modules.homeManager.default
  # ];

  home.homeDirectory = user.home;
  # until home-manager can handle nixpkgs 25.11
  home.enableNixpkgsReleaseCheck = false;
  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "24.11";
}
