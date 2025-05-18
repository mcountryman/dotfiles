{
  me,
  pkgs,
  ...
}: {
  home-manager.users.${me} = {
    programs.alacritty = {
      enable = true;
      settings = {
        env = {TERM = "xterm-256color";};

        terminal.shell = "${pkgs.fish}/bin/fish";

        font = {
          size = 13.0;
          # size = 18.0;
          normal = {
            # family = "AnonymicePro Nerd Font";
            # family = "ProggyClean CE Nerd Font";
            # family = "JetBrainsMono Nerd Font";
            # family = "FiraCode Nerd Font Mono";
            # family = "Iosevka";
            # family = "Iosevka Etoile";
            # family = "Iosevka Curly";
            # family = "Iosevka Nerd Font Mono";
            family = "IosevkaTerm Nerd Font";
            # family = "Hack Nerd Font Mono";
            style = "Regular";
          };
        };
        window = {
          decorations = "buttonless";
          dynamic_padding = true;
        };
        colors = {
          draw_bold_text_with_bright_colors = false;

          bright = {
            black = "0x665c54";
            blue = "0xbdae93";
            cyan = "0xd65d0e";
            green = "0x3c3836";
            magenta = "0xebdbb2";
            red = "0xfe8019";
            white = "0xfbf1c7";
            yellow = "0x504945";
          };
          cursor = {
            cursor = "0xd5c4a1";
            text = "0x1d2021";
          };
          normal = {
            black = "0x1d2021";
            blue = "0x83a598";
            cyan = "0x8ec07c";
            green = "0xb8bb26";
            magenta = "0xd3869b";
            red = "0xfb4934";
            white = "0xd5c4a1";
            yellow = "0xfabd2f";
          };
          primary = {
            background = "0x0c0d0e";
            foreground = "0xd5c4a1";
          };
        };
      };
    };
  };
}
