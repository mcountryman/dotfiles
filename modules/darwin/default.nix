{ me, pkgs, ... }:
{
  imports = [
    ./yabai.nix
    ./homebrew.nix
  ];

  system.primaryUser = me;

  # Use TouchID for `sudo` authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  system = {
    defaults = {
      # A futile attempt to nix `.DS_Store`
      CustomUserPreferences = {
        "com.apple.desktopservices" = {
          "DSDontWriteUSBStores" = true;
          "DSDontWriteNetworkStores" = true;
        };
      };

      # Fun defaults for Finder
      NSGlobalDomain = {
        AppleShowAllFiles = true;
        AppleInterfaceStyle = "Dark";
        AppleShowAllExtensions = true;
        AppleSpacesSwitchOnActivate = false;
        _HIHideMenuBar = false;
      };

      # Docks are for nerds
      dock = {
        autohide = true;
        autohide-delay = 6000.0;
      };
    };
  };

  environment.systemPackages = [
    # Apple `sed` makes C+P unverified shell scripts from stackoverflow hard
    pkgs.gnused
  ];
}
