{ pkgs, ... }:
{
  imports = [
    ./fish.nix
    ./fonts.nix
    ./stylish.nix
    ./nix-daemon.nix
  ];

  environment.variables.EDITOR = "hx";
  environment.variables.VISUAL = "hx";

  environment.systemPackages = with pkgs; [
    btop
  ];
}
