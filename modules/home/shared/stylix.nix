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
        name = "SpaceMono Nerd Font";
        package = pkgs.nerd-fonts.space-mono;
        # name = "IosevkaTerm Nerd Font";
        # package = pkgs.nerd-fonts.iosevka-term;
        # name = "ProggyClean Nerd Font";
        # package = pkgs.nerd-fonts.proggy-clean-tt;
      };

      sizes = {
        terminal = 12;
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
