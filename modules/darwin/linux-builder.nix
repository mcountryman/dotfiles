{inputs, ...}: {
  imports = [
    inputs.nix-rosetta-builder.darwinModules.default
  ];

  nix = {
    # # We need this to bootstrap nix-rosetta-builder..
    # linux-builder = {
    #   enable = true;
    #   config.virtualisation = {
    #     cores = 8;
    #     darwin-builder = {
    #       diskSize = 40 * 1024;
    #       memorySize = 16 * 1024;
    #     };
    #   };
    # };
  };
}
