_: {
  imports = [
    ./agents
    ./helix

    ./direnv.nix
    ./eza.nix
    ./fish.nix
    ./projects.nix
    ./sesh.nix
    ./starship.nix
    ./stylix.nix
    ./tmux.nix
    ./yazi.nix
    ./zellij.nix
    ./zoxide.nix
  ];

  home.enableNixpkgsReleaseCheck = false;
  home.stateVersion = "25.11";
}
