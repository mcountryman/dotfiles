{
  nixpkgs.hostPlatform = "aarch64-darwin";

  # is me
  dotfiles.users.marvin = {
    email = "me@maar.vin";
    fullName = "Marvin Countryman";
    primary = true;
  };

  # Random stuff I want on foldy-arm
  homebrew = {
    brews = [ "docker-buildx" ];
    casks = [
      "steam"
      "firefox"
      "moonlight"
      "tailscale"
    ];
  };
}
