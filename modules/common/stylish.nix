# stylish - shared theming

{ pkgs, ... }:

{
  stylix.enable = true;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/ayu-dark.yaml";
  # stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
  stylix.autoEnable = false;

  stylix.fonts = {
    # monospace = {
    #   package = pkgs.nerd-fonts.proggy-clean-tt;
    #   name = "ProggyClean CE Nerd Font Mono";
    # };

    monospace = {
      package = pkgs.nerd-fonts.iosevka-term;
      name = "IosevkaTerm Nerd Font";
    };

    sizes = {
      terminal = 14;
    };
  };
}
