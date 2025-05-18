{
  me,
  pkgs,
  ...
}:
let
  isLinux = pkgs.hostPlatform.isLinux;
in
{
  # TODO: Optional linux support
  homebrew.casks = [ "firefox" ];

  home-manager.users.${me} = {
    programs.firefox = {
      enable = isLinux;
      nativeMessagingHosts = [ pkgs.tridactyl-native ];

      # profiles.default = {
      #   id = 0;
      #   isDefault = true;
      #   userChrome = builtins.readFile ./firefox/userChrome.css;
      #   # userContent = builtins.readFile ./firefox/userContent.css;
      #   extensions = [
      #     extensions.tridactyl
      #     extensions.react-devtools
      #     extensions.ublock-origin
      #     extensions.onepassword-password-manager
      #   ];
      #
      #   search = {
      #     force = true;
      #     default = "DuckDuckGo";
      #   };
      #
      #   settings = {
      #     # Auto enable extensions
      #     "extensions.autoDisableScopes" = 0;
      #     # Customization
      #     "browser.startup.homepage" = "https://duckduckgo.com";
      #     "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      #     # Customization - Hide everything
      #     "browser.compactmode.show" = true;
      #     "browser.toolbars.bookmarks.visibility" = "never";
      #     "browser.uiCustomization.state" =
      #       builtins.readFile ./firefox/uiCustomization.state.json;
      #   };
      # };
    };
  };
}
