_: {
  imports = [
    ./stylix.nix
    ./helix
    ./fish.nix
    ./starship.nix
    ./tmux.nix
    ./zellij.nix
    ./yazi.nix
    ./direnv.nix
    ./eza.nix
    ./zoxide.nix
  ];

  home.enableNixpkgsReleaseCheck = false;
  home.stateVersion = "24.11";
}
