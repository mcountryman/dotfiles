{ pkgs, ... }:
{
  stylix.targets.yazi.enable = true;

  # File management
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
  };

  home.packages = with pkgs; [
    chafa
    ueberzugpp
  ];
}
