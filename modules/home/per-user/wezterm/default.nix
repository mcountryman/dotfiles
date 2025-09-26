{ config, ... }:
{
  programs.wezterm.enable = !config.dotfiles.headless;

  xdg.configFile."wezterm" = {
    source = ./config;
    recursive = true;
  };
}
