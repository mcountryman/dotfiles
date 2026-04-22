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
    # nixos-apple-silicon.url = "github:nix-community/nixos-apple-silicon";
    # nixos-apple-silicon.inputs.nixpkgs.follows = "nixpkgs";

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
    # helix.url = "github:helix-editor/helix/079f544260f4f5eaff08104bf07abd57bfb7b611";
    helix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      eachPkgs = fn: eachSystem (system: fn (import nixpkgs { inherit system; }));
      eachSystem = nixpkgs.lib.genAttrs systems;

      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
    in
    {
      darwinConfigurations."foldy-arm" = inputs.nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          inputs.self.darwinModules.default
          ./hosts/foldy-arm
        ];
      };

      darwinModules.default = inputs.self.darwinModules.dotfiles;
      darwinModules.dotfiles = import ./modules/darwin inputs;

      formatter = eachPkgs (pkgs: pkgs.nixfmt-tree);

      checks = eachPkgs (pkgs: {
        # Verify all .nix files are formatted with nixfmt-rfc-style.
        # Run `nix fmt` to fix failures.
        formatting = pkgs.runCommand "check-formatting" { } ''
          ${pkgs.lib.getExe pkgs.nixfmt} --check $(find ${./.} -name "*.nix")
          touch $out
        '';

        # Static analysis: common Nix anti-patterns and style issues.
        statix = pkgs.runCommand "check-statix" { } ''
          ${pkgs.lib.getExe pkgs.statix} check ${./.}
          touch $out
        '';

        # Dead code: unused bindings, redundant `with` expressions, etc.
        deadnix = pkgs.runCommand "check-deadnix" { } ''
          ${pkgs.lib.getExe pkgs.deadnix} --fail ${./.}
          touch $out
        '';

        # One eval-only check per darwinConfiguration in the flake.
        darwinConfigurations = pkgs.runCommand "check-darwin-configurations" { } (
          let
            eachMatchingConfig =
              fn:
              pkgs.lib.pipe inputs.self.darwinConfigurations [
                (pkgs.lib.filterAttrs (_: v: pkgs.stdenv.hostPlatform.system == v.pkgs.stdenv.hostPlatform.system))
                (pkgs.lib.mapAttrs (_: fn))
                pkgs.lib.attrValues
              ];
          in
          pkgs.lib.concatStringsSep "\n" (
            [ "touch $out" ]
            ++ eachMatchingConfig (cfg: "echo ${toString cfg.config.system.stateVersion} >> $out")
          )
        );
      });
    };
}
