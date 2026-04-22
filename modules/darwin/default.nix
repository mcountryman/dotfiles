{
  self,
  helix,
  homebrew-cask,
  homebrew-core,
  homebrew-bundle,
  home-manager,
  nix-homebrew,
  nix-rosetta-builder,
  sops-nix,
  ...
}:
{
  imports = [
    (import ./home.nix { inherit self home-manager; })
    nix-homebrew.darwinModules.nix-homebrew
    nix-rosetta-builder.darwinModules.default
    sops-nix.darwinModules.sops

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
        helix.overlays.default
      ];

      nix-homebrew.taps = {
        "homebrew/homebrew-cask" = homebrew-cask;
        "homebrew/homebrew-core" = homebrew-core;
        "homebrew/homebrew-bundle" = homebrew-bundle;
      };

      system.stateVersion = 5;
    }
  ];
}
