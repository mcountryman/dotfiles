{ pkgs, user, ... }:

{
  home-manager.users.${user} = {
    programs.zellij.enable = true;

    xdg.configFile."zellij/config.kdl".text = ''
      theme "ayu_dark"
      pane_frames false 
      default_shell "${pkgs.fish}/bin/fish"
      default_layout "compact"

      keybinds clear-defaults=true {
          normal {
              bind "Ctrl b" { SwitchToMode "Tmux"; }

              bind "Ctrl H" { Resize "Increase Left"; }
              bind "Ctrl J" { Resize "Increase Down"; }
              bind "Ctrl K" { Resize "Increase Up"; }
              bind "Ctrl L" { Resize "Increase Right"; }

              bind "Ctrl h" { MoveFocus "Left"; }
              bind "Ctrl j" { MoveFocus "Down"; }
              bind "Ctrl k" { MoveFocus "Up"; }
              bind "Ctrl l" { MoveFocus "Right"; }
          }

          tmux {
              bind "Esc" { SwitchToMode "Normal"; }
              bind "s" {
                  LaunchOrFocusPlugin "zellij:session-manager" {
                      floating true
                      move_to_focused_tab true
                  };
                  SwitchToMode "Normal"
              }
         
              bind "[" { SwitchToMode "Scroll"; }
              bind "Ctrl b" { Write 2; SwitchToMode "Normal"; }
              bind "-" { NewPane "Down"; SwitchToMode "Normal"; }
              bind "\\" { NewPane "Right"; SwitchToMode "Normal"; }
              bind "f" { ToggleFloatingPanes; SwitchToMode "Normal"; }
              bind "z" { ToggleFocusFullscreen; SwitchToMode "Normal"; }

              bind "c" { NewTab; SwitchToMode "Normal"; }
              bind "," { SwitchToMode "RenameTab"; }
              bind "p" { GoToPreviousTab; SwitchToMode "Normal"; }
              bind "n" { GoToNextTab; SwitchToMode "Normal"; }

              bind "h" { MoveFocus "Left"; SwitchToMode "Normal"; }
              bind "l" { MoveFocus "Right"; SwitchToMode "Normal"; }
              bind "j" { MoveFocus "Down"; SwitchToMode "Normal"; }
              bind "k" { MoveFocus "Up"; SwitchToMode "Normal"; }

              bind "d" { Detach; }
              bind "Space" { NextSwapLayout; }
              bind "x" { CloseFocus; SwitchToMode "Normal"; }

              bind "Up" { Resize "Increase"; }
              bind "Down" { Resize "Decrease"; }
          }

          renametab {
              bind "Esc" { SwitchToMode "Normal"; }
              bind "Enter" { SwitchToMode "Normal"; }
          }

          renamepane {
              bind "Esc" { SwitchToMode "Normal"; }
              bind "Enter" { SwitchToMode "Normal"; }
          }
      }
    '';
  };
}
