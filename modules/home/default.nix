{ config, ... }:
{
  home-manager.useGlobalPkgs = true;
  # home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "home-manager.bak";
  home-manager.users = builtins.mapAttrs (_: user: {
    # Provide a `user` arg for more modularity
    _module.args.user = user;

    dotfiles = config.dotfiles;
    imports = [
      ../default.nix
      ./per-user/alacritty.nix
      ./per-user/firefox
      ./per-user/fish.nix
      ./per-user/git.nix
      ./per-user/gpg.nix
      ./per-user/keychain.nix
      ./per-user/helix
      ./per-user/yazi.nix
      ./per-user/zellij.nix

      # FIXME: Only enable on linux
      ./per-user/hyprland
    ];

    # until home-manager can handle nixpkgs 25.11
    home.enableNixpkgsReleaseCheck = false;
    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = "24.11";
  }) config.dotfiles.users;
}
