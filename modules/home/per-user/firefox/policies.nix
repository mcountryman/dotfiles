{
  programs.firefox.policies = {
    # I have my own thank you very much
    DNSOverHTTPS.Enabled = false;

    # Disable the bloat
    DisablePocket = true;
    DisableTelemetry = true; # no spy pls
    DontCheckDefaultBrowser = true;
    DisableFirefoxStudies = true;
    DisableFirefoxAccounts = true;
    DisableFirefoxScreenshots = true;

    # Hide things I don't use
    DisplayMenuBar = "never";
    DisplayBookmarksToolbar = "never";

    # Random tweaks
    OverrideFirstRunPage = "";
    PromptForDownloadLocation = true;
    TranslateEnabled = true;
    HardwareAcceleration = true;
    Homepage.StartPage = "previous-session";

    UserMessaging = {
      UrlbarInterventions = false;
      SkipOnboarding = true;
    };

    # I know what I want goddammit
    FirefoxSuggest = {
      WebSuggestions = false;
      SponsoredSuggestions = false;
      ImproveSuggest = false;
    };

    # No track me pls
    EnableTrackingProtection = {
      Value = true;
      Cryptomining = true;
      Fingerprinting = true;
    };

    # Hide sponsored garbage
    FirefoxHome = {
      Search = true;
      TopSites = true;
      SponsoredTopSites = false;
      Highlights = false;
      Pocket = false;
      SponsoredPocket = false;
      Snippets = false;
    };
  };
}
