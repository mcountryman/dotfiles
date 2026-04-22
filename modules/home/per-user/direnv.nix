{
  # Automatic environment setup when `cd`-ing into a dir
  programs.direnv = {
    enable = true;

    nix-direnv.enable = true;
  };
}
