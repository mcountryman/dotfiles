{ pkgs, ... }:
{
  stylix.targets.yazi.enable = true;

  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      mgr = {
        ratio = [
          0
          4
          4
        ];
      };

      preview = {
        # Reduce image protocol detection timeout time for tmux
        image_delay = 0;
      };
    };

    keymap = {
      mgr.append_keymap = [
        {
          run = "quit --no-cwd-file";
          on = [
            "q"
          ];
        }
      ];
    };
  };

  home.packages = with pkgs; [
    chafa
    ueberzugpp
  ];
}
