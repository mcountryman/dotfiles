{ config, ... }:
{
  home-manager = {
    useGlobalPkgs = true;
    # useUserPackages = true;
    backupFileExtension = "home-manager.bak";
    users = builtins.mapAttrs (_: user: {
      inherit (config) dotfiles;

      # Provide a `user` arg for more modularity
      _module.args.user = user;

      imports = [
        ./per-user/helix
        ./per-user/firefox
        # ./per-user/wezterm

        ../default.nix
        ./per-user/alacritty.nix
        ./per-user/direnv.nix
        ./per-user/eza.nix
        ./per-user/fish.nix
        ./per-user/ghostty.nix
        ./per-user/git.nix
        ./per-user/gpg.nix
        ./per-user/keychain.nix
        ./per-user/starship.nix
        ./per-user/tmux.nix
        ./per-user/yazi.nix
        ./per-user/zellij.nix
        ./per-user/zoxide.nix
      ];

      # until home-manager can handle nixpkgs 25.11
      home.enableNixpkgsReleaseCheck = false;
      # The state version is required and should stay at the version you
      # originally installed.
      home.stateVersion = "24.11";
    }) config.dotfiles.users;
  };
}
