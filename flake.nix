{
  description = "My nixos driven dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Home management
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Darwin
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Apple silicon
    nixos-apple-silicon.url = "github:nix-community/nixos-apple-silicon";
    nixos-apple-silicon.inputs.nixpkgs.follows = "nixpkgs";

    # Homebrew
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    homebrew-core.url = "github:homebrew/homebrew-core";
    homebrew-core.flake = false;

    homebrew-cask.url = "github:homebrew/homebrew-cask";
    homebrew-cask.flake = false;

    homebrew-bundle.url = "github:homebrew/homebrew-bundle";
    homebrew-bundle.flake = false;

    # Cross OS/arch builder.  Look at the readme for details when setting up
    # from scratch.  Requires some bootstrap jazz.
    nix-rosetta-builder.url = "github:cpick/nix-rosetta-builder";
    nix-rosetta-builder.inputs.nixpkgs.follows = "nixpkgs";

    # Make it pretty
    stylix.url = "github:nix-community/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    # shhh
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    helix.url = "github:helix-editor/helix";
    helix.inputs.nixpkgs.follows = "nixpkgs";

    hyprland.url = "github:hyprwm/hyprland";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: {
    darwinConfigurations."foldy-arm" = inputs.nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        inputs.self.darwinModules.default
        ./hosts/foldy-arm
      ];
    };

    nixosConfigurations."foldy-nix" = inputs.nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        inputs.self.nixosModules.default
        inputs.nixos-apple-silicon.nixosModules.default
        ./hosts/foldy-nix
      ];
    };

    overlays = import ./overlays ++ [
      inputs.helix.overlays.default
    ];

    nixosModules.default = {
      imports = [
        inputs.sops-nix.nixosModules.sops
        inputs.stylix.nixosModules.stylix
        inputs.home-manager.nixosModules.home-manager

        ./modules
        ./modules/home
        ./modules/common
        ./modules/nixos

        {
          nixpkgs.overlays = inputs.self.overlays;
        }
      ];
    };

    darwinModules.default = {
      imports = [
        inputs.sops-nix.darwinModules.sops
        inputs.stylix.darwinModules.stylix
        inputs.home-manager.darwinModules.home-manager
        inputs.nix-homebrew.darwinModules.nix-homebrew
        inputs.nix-rosetta-builder.darwinModules.default

        ./modules
        ./modules/home
        ./modules/common
        ./modules/darwin
        {
          nixpkgs.overlays = inputs.self.overlays;

          # Until I figure out a good way to pass down `inputs` we'll just make
          # sure all inputs are accessed from `flake.nix`.
          nix-homebrew.taps = {
            "homebrew/homebrew-core" = inputs.homebrew-core;
            "homebrew/homebrew-cask" = inputs.homebrew-cask;
            "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
          };
        }
      ];
    };
  };
}
