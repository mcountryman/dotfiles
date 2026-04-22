{
  stylix.targets.starship.enable = true;

  # Straight forward prompt giving me most of the information I want to see
  #
  # TODO: Consider trimming down the modules.  I probably don't need all of what
  # is shown by default.
  programs.starship = {
    enable = true;
    settings = {
      format = " $all";
      character = {
        error_symbol = " [>](bold red)";
        success_symbol = " [>](bold green)";
      };
    };
  };
}
