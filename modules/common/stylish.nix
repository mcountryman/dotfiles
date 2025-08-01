# stylish - shared theming

{ pkgs, ... }:
{
  stylix.enable = true;
  # stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/ayu-dark.yaml";
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
  stylix.autoEnable = false;

  stylix.fonts = rec {
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
      terminal = 13;
    };
  };

  stylix.opacity = rec {
    applications = 0.8;
    desktop = applications;
    popups = applications;
    terminal = applications;
  };

  stylix.image = ./wallpaper.jpg;
}
