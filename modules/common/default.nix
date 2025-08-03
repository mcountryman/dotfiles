{ pkgs, ... }:
{
  imports = [
    ./fish.nix
    ./fonts.nix
    ./gnupg.nix
    ./stylish.nix
    ./nix-daemon.nix
  ];

  environment.variables.EDITOR = "hx";
  environment.variables.VISUAL = "hx";

  # TODO: Find a good setup for per-project rust configuration. Until then I'll
  # deal with the non-declarative nature of `rustup` + `cargo`
  environment.systemPackages = with pkgs; [
    btop
    rustup
  ];
}
