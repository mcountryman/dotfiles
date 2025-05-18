{ ... }:
{
  homebrew = {
    brews = [ "docker-buildx" ];

    # Uncatogorized casks
    casks = [
      "steam"
      "moonlight"
      "tailscale"
    ];
  };

  # # Set Git commit hash for darwin-version.
  # configurationRevision = self.rev or self.dirtyRev or null;
  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;
}
