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
      macos-titlebar-style = "hidden";
    };
  };
}
