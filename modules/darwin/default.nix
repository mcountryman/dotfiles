{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) pipe;
  inherit (builtins) head filter attrValues;

  primaryUser = pipe config.dotfiles.users [
    attrValues
    (filter (u: u.primary))
    (map (u: u.name))
    head
  ];
in
{
  imports = [
    ./yabai.nix
    ./homebrew.nix
    ./linux-builder.nix
  ];

  # Use TouchID for `sudo` authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  system = {
    primaryUser = primaryUser;

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

  users.users = builtins.mapAttrs (_: user: {
    home = "/Users/${user.name}";
  }) config.dotfiles.users;

  environment.systemPackages = [
    # Apple `sed` makes C+P unverified shell scripts from stackoverflow hard
    pkgs.gnused
  ];

  # # Set Git commit hash for darwin-version.
  # configurationRevision = self.rev or self.dirtyRev or null;
  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;
}
