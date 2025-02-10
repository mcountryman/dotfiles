{ ... }:

{
  homebrew = {
    enable = true;

    brews = [ "docker-buildx" ];

    # Uncatogorized casks
    casks = [
      # 1password really wants to be in `/Applications`.  According to the nixpkgs
      # package this isn't possible so we are relying on homebrew to install.
      "1password"
      "1password-cli"

      "steam"
      "moonlight"
      "zen-browser"
      "tailscale"
    ];

    # Install apps from MacAppStore.
    masApps = { };

    # Cleanup unused packages on rebuild
    onActivation.cleanup = "zap";
  };
}
