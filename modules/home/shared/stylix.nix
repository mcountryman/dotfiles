{ pkgs, ... }:
{
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    autoEnable = false;

    fonts = rec {
      serif = sansSerif;
      sansSerif = {
        name = "DejuVu Sans";
        package = pkgs.dejavu_fonts;
      };

      emoji = {
        name = "Noto Color Emoji";
        package = pkgs.noto-fonts-noto-fonts-emoji;
      };

      monospace = {
        name = "IosevkaTerm Nerd Font";
        package = pkgs.nerd-fonts.iosevka-term;
      };

      sizes = {
        terminal = 16;
      };
    };

    opacity = rec {
      applications = 0.8;
      desktop = applications;
      popups = applications;
      terminal = applications;
    };

    image = ../../shared/wallpaper.jpg;
  };
}
