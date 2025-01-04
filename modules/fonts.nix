{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    nerd-fonts.iosevka
    nerd-fonts.iosevka-term
    nerd-fonts.iosevka-term-slab
    nerd-fonts.proggy-clean-tt

    # -
  ];
}
