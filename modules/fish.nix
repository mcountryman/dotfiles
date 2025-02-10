{ pkgs, user, ... }:

{
  # Enable alternative shell support in nix-darwin.
  programs.fish.enable = true;
  # Set the user's login shell
  users.users.${user}.shell = "${pkgs.fish}/bin/fish";

  home-manager.users.${user} = {
    programs.fish = {
      enable = true;

      shellAliases = {
        "ls" = "exa";
        "la" = "exa -la";
      };

      interactiveShellInit = ''
        set fish_greeting # Disable greeting

        ${pkgs.starship}/bin/starship init fish | source
      '';

      plugins = [ ];
    };

    # fish : prompt
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

    # fish : cd
    programs.zoxide = {
      enable = true;
      enableFishIntegration = true;
      options = [ "--cmd cd" ];
    };

    # fish : la
    programs.eza = {
      enable = true;
      enableFishIntegration = true;
    };

    programs.yazi = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}

# # Aliases
# alias ls exa
# alias la "exa -la"
#
# # Environment
# set -gx PATH /usr/local/bin $PATH
# set -gx PATH "$HOME/.cargo/bin" $PATH
# set -gx PATH /opt/homebrew/dotnet/bin $PATH
# set -gx PATH /opt/homebrew/opt/openjdk/bin $PATH
# set -gx PATH "$HOME/flutter/bin" $PATH
# set -gx PATH "$(go env GOPATH)/bin" $PATH
# set -gx PATH /opt/homebrew/opt/llvm/bin $PATH
#
# set -gx PNPM_HOME /Users/marvin/Library/pnpm
# set -gx DOTNET_ROOT /opt/homebrew/opt/dotnet/libexec
# set -gx ANDROID_HOME "$HOME/Library/Android/sdk"
# set -gx WASMTIME_HOME "$HOME/.wasmtime"
#
# set -gx PATH "$PNPM_HOME" $PATH
# set -gx PATH "$ANDROID_HOME/platform-tools" $PATH
# set -gx PATH "$ANDROID_HOME/tools" $PATH
#
# set -gx HOMEBREW_NO_AUTO_UPDATE 1
# set -gx LIBRARY_PATH "$(brew --prefix)/lib"
#
# starship init fish | source
#
# function fish_greeting
#     echo '                  '(set_color F00)'___
#    ___======____='(set_color FF7F00)'-'(set_color FF0)'-'(set_color FF7F00)'-='(set_color F00)')
#  /T            \_'(set_color FF0)'--='(set_color FF7F00)'=='(set_color F00)')    '(set_color red)(whoami)'@'(hostname)'
#  [ \ '(set_color FF7F00)'('(set_color FF0)'0'(set_color FF7F00)')   '(set_color F00)'\~    \_'(set_color FF0)'-='(set_color FF7F00)'='(set_color F00)')'(set_color yellow)'    Uptime: '(set_color white)(uptime | sed 's/.*up \([^,]*\), .*/\1/')(set_color red)'
#   \      / )J'(set_color FF7F00)'~~    \\'(set_color FF0)'-='(set_color F00)')    IP Address: '(set_color white)(ipconfig getifaddr en0)(set_color red)'
#    \\\\___/  )JJ'(set_color FF7F00)'~'(set_color FF0)'~~   '(set_color F00)'\)     '(set_color yellow)'Version: '(set_color white)(echo $FISH_VERSION)(set_color red)'
#     \_____/JJJ'(set_color FF7F00)'~~'(set_color FF0)'~~    '(set_color F00)'\\
#     '(set_color FF7F00)'/ '(set_color FF0)'\  '(set_color FF0)', \\'(set_color F00)'J'(set_color FF7F00)'~~~'(set_color FF0)'~~     '(set_color FF7F00)'\\
#    (-'(set_color FF0)'\)'(set_color F00)'\='(set_color FF7F00)'|'(set_color FF0)'\\\\\\'(set_color FF7F00)'~~'(set_color FF0)'~~       '(set_color FF7F00)'L_'(set_color FF0)'_
#    '(set_color FF7F00)'('(set_color F00)'\\'(set_color FF7F00)'\\)  ('(set_color FF0)'\\'(set_color FF7F00)'\\\)'(set_color F00)'_           '(set_color FF0)'\=='(set_color FF7F00)'__
#     '(set_color F00)'\V    '(set_color FF7F00)'\\\\'(set_color F00)'\) =='(set_color FF7F00)'=_____   '(set_color FF0)'\\\\\\\\'(set_color FF7F00)'\\\\
#            '(set_color F00)'\V)     \_) '(set_color FF7F00)'\\\\'(set_color FF0)'\\\\JJ\\'(set_color FF7F00)'J\)
#                        '(set_color F00)'/'(set_color FF7F00)'J'(set_color FF0)'\\'(set_color FF7F00)'J'(set_color F00)'T\\'(set_color FF7F00)'JJJ'(set_color F00)'J)
#                        (J'(set_color FF7F00)'JJ'(set_color F00)'| \UUU)
#                         (UU)'(set_color normal)
# end
#
# # pnpm
# # pnpm end
#
# zoxide init fish --cmd cd | source
#
# string match -r ".wasmtime" "$PATH" >/dev/null; or set -gx PATH "$WASMTIME_HOME/bin" $PATH
#
# # bun
# set --export BUN_INSTALL "$HOME/.bun"
# set --export PATH $BUN_INSTALL/bin $PATH
