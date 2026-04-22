{ pkgs, ... }:
{
  imports = [
    ./fish.nix
    ./fonts.nix
    ./stylish.nix
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
