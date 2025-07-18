{
  programs.firefox.policies.Preferences = {
    "browser.urlbar.suggest.searches" = true; # Need this for basic search suggestions
    "browser.urlbar.shortcuts.bookmarks" = false;
    "browser.urlbar.shortcuts.history" = false;
    "browser.urlbar.shortcuts.tabs" = false;

    "browser.tabs.tabMinWidth" = 75; # Make tabs able to be smaller to prevent scrolling

    "browser.urlbar.placeholderName" = "DuckDuckGo";
    "browser.urlbar.placeholderName.private" = "DuckDuckGo";

    "browser.aboutConfig.showWarning" = false; # No warning when going to config
    "browser.warnOnQuitShortcut" = false;

    "browser.tabs.loadInBackground" = true; # Load tabs automatically

    "gfx.webrender.all" = true;
    "media.ffmpeg.vaapi.enabled" = true; # Enable hardware acceleration
    "layers.acceleration.force-enabled" = true;

    "ui.systemUsesDarkTheme" = true;
    "browser.in-content.dark-mode" = true; # Use dark mode

    "extensions.update.enabled" = false;
    "extensions.autoDisableScopes" = 0; # Automatically enable extensions

    "browser.uiCustomization.state" = builtins.toJSON {
      placements = {
        widget-overflow-fixed-list = [ ];
        toolbar-menubar = [ "menubar-items" ];
        PersonalToolbar = [ "personal-bookmarks" ];
        nav-bar = [
          "back-button"
          "forward-button"
          "urlbar-container"
          "downloads-button"
          "unified-extensions-button"
        ];
        TabsToolbar = [
          "firefox-view-button"
          "tabbrowser-tabs"
          "new-tab-button"
        ];
      };

      currentVersion = 22;
      newElementCount = 3;
    };
  };
}
