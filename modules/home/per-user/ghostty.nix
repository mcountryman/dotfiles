{ pkgs, ... }:
{
  stylix.targets.ghostty.enable = true;

  programs.ghostty = {
    package = pkgs.ghostty-bin;

    enable = true;
    enableFishIntegration = true;
    settings = {
      command = "${pkgs.fish}/bin/fish";
      font-thicken = true;
      # font-thicken-strength = 1;
      macos-titlebar-style = "hidden";
    };
  };

}
