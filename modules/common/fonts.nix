{ pkgs, ... }:
{
  fonts.packages = [
    pkgs.nerd-fonts.iosevka
    pkgs.nerd-fonts.iosevka-term
    pkgs.nerd-fonts.iosevka-term-slab
    pkgs.nerd-fonts.proggy-clean-tt

    # -
  ];
}
