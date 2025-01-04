{
  description = "Nix config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # nix-community pkgs
    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "nixpkgs";

    # Secrets
    agenix.url = "github:ryantm/agenix";

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
  };

  outputs = { self, agenix, nur, nix-darwin, nix-homebrew, nixpkgs, home-manager
    , homebrew-core, homebrew-cask, homebrew-bundle, ... }@inputs:
    let
      user = "marvin";
      systemsDarwin = [ "foldy-arm" ];
      systemsLinux = [ ];
      systems = f: nixpkgs.lib.genAttrs (systemsDarwin ++ systemsLinux) f;
    in {
      darwinConfigurations = nixpkgs.lib.genAttrs systemsDarwin (system:
        nix-darwin.lib.darwinSystem {
          inherit system;

          specialArgs = {
            inherit user;
            inherit inputs;
          };

          modules = [
            # Secrets
            agenix.nixosModules.default
            # Overlays
            { nixpkgs.overlays = [ nur.overlays.default ]; }

            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "home-manager.bak";
              home-manager.users.${user} = {
                imports = [ nur.modules.homeManager.default ];
                # The state version is required and should stay at the version you
                # originally installed.
                home.stateVersion = "24.11";
              };
            }
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                inherit user;

                enable = true;
                enableRosetta = false;

                taps = {
                  "homebrew/homebrew-core" = homebrew-core;
                  "homebrew/homebrew-cask" = homebrew-cask;
                  "homebrew/homebrew-bundle" = homebrew-bundle;
                };

                mutableTaps = false;
              };
            }
            ./hosts/${system}
          ];
        });
    };
}
