let
  green = "0xffaad94c";
in
{
  services.jankyborders = {
    enable = true;
    width = 1.0;
    hidpi = true;
    order = "above";
    active_color = "${green}";
    inactive_color = "0x00000000";
  };
}
