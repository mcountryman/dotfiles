{ pkgs, ... }:
{
  stylix.targets.yazi.enable = true;

  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      preview = {
        # Reduce image protocol detection timeout time for tmux
        image_delay = 0;
      };
    };
  };

  home.packages = with pkgs; [
    chafa
    ueberzugpp
  ];
}
