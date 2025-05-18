{ inputs, ... }:
{
  imports = [
    inputs.nix-rosetta-builder.darwinModules.default
    { nix-rosetta-builder.onDemand = true; }
  ];

  nix = {
    #  We need this to bootstrap nix-rosetta-builder..
    linux-builder.enable = true;
  };
}
