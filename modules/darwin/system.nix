{
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
}
