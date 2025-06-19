{ config, ... }:
{
  home-manager.useGlobalPkgs = true;
  # home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "home-manager.bak";
  home-manager.users = builtins.mapAttrs (_: user: {
    _module.args.user = user;

    imports = [
      ./per-user/alacritty.nix
      ./per-user/fish.nix
      ./per-user/git.nix
      ./per-user/keychain.nix
      ./per-user/helix
      ./per-user/yazi.nix
      ./per-user/zellij.nix
    ];

    # until home-manager can handle nixpkgs 25.11
    home.enableNixpkgsReleaseCheck = false;
    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = "24.11";
  }) config.dotfiles.users;
}
