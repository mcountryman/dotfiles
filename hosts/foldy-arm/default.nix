{ pkgs, user, ... }:

{
  imports = [
    # Shared
    ../../modules/fish.nix
    ../../modules/fonts.nix
    ../../modules/helix.nix
    ../../modules/zellij.nix
    ../../modules/firefox.nix
    ../../modules/alacritty.nix

    # Darwin
    ../../modules/darwin/brew.nix
    ../../modules/darwin/yabai.nix
  ];

  nix = {
    # # We need this to bootstrap nix-rosetta-builder..
    # linux-builder = {
    #   enable = true;
    #   config.virtualisation = {
    #     cores = 8;
    #     darwin-builder = {
    #       diskSize = 40 * 1024;
    #       memorySize = 16 * 1024;
    #     };
    #   };
    # };

    settings.trusted-users = [ "@admin" user ];
    # Necessary for using flakes on this system.
    settings.experimental-features = "nix-command flakes";
  };

  users.users = {
    ${user} = {
      name = user;
      home = "/Users/${user}";
    };
  };

  system = {
    # # Set Git commit hash for darwin-version.
    # configurationRevision = self.rev or self.dirtyRev or null;
    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    stateVersion = 5;

    defaults = {
      CustomUserPreferences = {
        "com.apple.desktopservices" = {
          "DSDontWriteUSBStores" = true;
          "DSDontWriteNetworkStores" = true;
        };
      };

      NSGlobalDomain = {
        AppleShowAllFiles = true;
        AppleInterfaceStyle = "Dark";
        AppleShowAllExtensions = true;
        AppleSpacesSwitchOnActivate = false;
        _HIHideMenuBar = false;
      };

      dock = {
        # Docks are for nerds
        autohide = true;
        autohide-delay = 6000.0;
      };
    };
  };

  # The platform the configuration will be used on.
  nixpkgs = {
    config.allowBroken = true;
    config.allowUnfree = true;

    hostPlatform = "aarch64-darwin";
  };

  environment = {
    # List packages installed in system profile. To search by name, run:
    # $ nix-env -qaP | grep wget
    systemPackages = [ pkgs.gnused ];
  };
}
