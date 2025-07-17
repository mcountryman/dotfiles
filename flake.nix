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

    # shhh
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    helix-flake.url = "github:helix-editor/helix";
    helix-flake.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: {
    darwinConfigurations."foldy-arm" = inputs.nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        # Excluded to avoid conflicts when using this flake as a module. There 
        # is likely a better way to do this so that consumers don't have to find
        # out that `sops` is required.
        inputs.sops-nix.darwinModules.sops
        inputs.self.darwinModules.default
        ./hosts/foldy-arm
      ];
    };

    nixosModules.default = {
      imports = [
        inputs.stylix.nixosModules.stylix
        inputs.home-manager.nixosModules.home-manager

        ./modules
        ./modules/home
        ./modules/common
        ./modules/nixos

        { nixpkgs.overlays = [ inputs.helix-flake.overlays.default ]; }
      ];
    };

    darwinModules.default = {
      imports = [
        inputs.stylix.darwinModules.stylix
        inputs.home-manager.darwinModules.home-manager
        inputs.nix-homebrew.darwinModules.nix-homebrew
        inputs.nix-rosetta-builder.darwinModules.default

        ./modules
        ./modules/home
        ./modules/common
        ./modules/darwin
        {
          nixpkgs.overlays = [ inputs.helix-flake.overlays.default ];

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
