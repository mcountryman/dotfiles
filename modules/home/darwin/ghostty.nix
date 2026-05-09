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
      adjust-cell-width = "-6%";
      macos-titlebar-style = "hidden";
    };
  };
}
