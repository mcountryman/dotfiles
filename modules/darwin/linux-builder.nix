{
  # # Uncomment this if you don't already have nix-rosetta-builder setup.
  # #
  # # nix-nix-rosetta-builder requires a linux system in order to be built. The
  # # recommended way and my only tested way to do this is with the nix default
  # # linux-builder.
  # nix = {
  #   linux-builder.enable = true;
  # };

  nix-rosetta-builder = {
    cores = 4;
    memory = "24GiB";
    onDemand = true;
    permitNonRootSshAccess = true;
  };
}
