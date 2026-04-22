{
  stylix.targets.starship.enable = true;

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
