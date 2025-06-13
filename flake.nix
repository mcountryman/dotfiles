{
  description = "My nixos driven dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # nix-community pkgs
    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "nixpkgs";

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
  };

  outputs = inputs: {
    darwinConfigurations."foldy-arm" = inputs.nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        inputs.self.darwinModules.default
        ./hosts/foldy-arm.nix
      ];
    };

    nixosModules.default = {
      _module.args.inputs = inputs;

      imports = [
        inputs.stylix.nixosModules.stylix
        inputs.home-manager.nixosModules.home-manager

        ./modules
        ./modules/home
        ./modules/common
        ./modules/nixos
      ];
    };

    darwinModules.default = {
      _module.args.inputs = inputs;

      imports = [
        inputs.stylix.darwinModules.stylix
        inputs.home-manager.darwinModules.home-manager
        inputs.nix-homebrew.darwinModules.nix-homebrew
        inputs.nix-rosetta-builder.darwinModules.default

        ./modules
        ./modules/home
        ./modules/common
        ./modules/darwin
      ];
    };
  };
}
