_: {
  imports = [
    ./helix

    ./direnv.nix
    ./eza.nix
    ./fish.nix
    ./sesh.nix
    ./starship.nix
    ./stylix.nix
    ./tmux.nix
    ./yazi.nix
    ./zellij.nix
    ./zoxide.nix
  ];

  home.enableNixpkgsReleaseCheck = false;
  home.stateVersion = "24.11";
}
