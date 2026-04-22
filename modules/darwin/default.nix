inputs: {
  imports = [
    inputs.sops-nix.darwinModules.sops
    inputs.stylix.darwinModules.stylix
    inputs.home-manager.darwinModules.home-manager
    inputs.nix-homebrew.darwinModules.nix-homebrew
    inputs.nix-rosetta-builder.darwinModules.default

    ../.
    ../home
    ../shared

    ./homebrew.nix
    ./jankyborders.nix
    ./linux-builder.nix
    ./security.nix
    ./system.nix
    ./systemPackages.nix
    ./users.nix
    ./yabai.nix
    {
      nixpkgs.overlays = [
        inputs.helix.overlays.default
      ];

      # Until I figure out a good way to pass down `inputs` we'll just make
      # sure all inputs are accessed from `flake.nix`.
      nix-homebrew.taps = {
        "homebrew/homebrew-core" = inputs.homebrew-core;
        "homebrew/homebrew-cask" = inputs.homebrew-cask;
        "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
      };

      # Set Git commit hash for darwin-version.
      # configurationRevision = self.rev or self.dirtyRev or null;
      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;
    }
  ];
}
