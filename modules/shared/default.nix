{ pkgs, ... }:
{
  imports = [
    ./fish.nix
    ./fonts.nix
    ./nix-daemon.nix
  ];

  environment = {
    variables = {
      EDITOR = "hx";
      VISUAL = "hx";
    };

    systemPackages = with pkgs; [
      git
      btop
    ];
  };
}
