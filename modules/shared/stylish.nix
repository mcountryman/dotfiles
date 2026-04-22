# stylish - shared theming

{ pkgs, ... }:
{
  stylix = {
    enable = true;
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/ayu-dark.yaml";
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
        # name = "ProggyClean Nerd Font";
        # package = pkgs.nerd-fonts.proggy-clean-tt;
        name = "IosevkaTerm Nerd Font";
        package = pkgs.nerd-fonts.iosevka-term;
        # name = "SpaceMono Nerd Font Propo";
        # package = pkgs.nerd-fonts.space-mono;
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

    image = ./wallpaper.jpg;
  };
}
