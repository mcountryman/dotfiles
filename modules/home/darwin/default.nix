{ stylix, ... }@inputs:
{
  imports = [
    stylix.homeModules.stylix
    (import ../shared inputs)
    ./ghostty.nix
    ./alacritty.nix
  ];
}
