{ pkgs, ... }:
{
  imports = [
    ./policies.nix
    ./extensions.nix
    ./preferences.nix
  ];

  programs.firefox = {
    enable = true;
    package = pkgs.librewolf-wayland;

    # Profile
    profiles.default = {
      isDefault = true;
    };

    # Search engines
    profiles.default.search = {
      force = true;
      default = "duckduckgo";
      engines = {
        # Disable all the stupid "This time, search with" icons
        "google".metaData.hidden = true;
        "bing".metaData.hidden = true;
        "ebay".metaData.hidden = true;
        "amazon".metaData.hidden = true;
        "wikipedia".metaData.hidden = true;
      };
    };
  };

  home.file.".librewolf/librewolf.overrides.cfg".text = ''
    defaultPref("privacy.clearOnShutdown.cache", false);
    defaultPref("privacy.clearOnShutdown.cookies", false);
    defaultPref("privacy.clearOnShutdown.downloads", false);
    defaultPref("privacy.clearOnShutdown.formdata", false);
    defaultPref("privacy.clearOnShutdown.history", false);
    defaultPref("privacy.clearOnShutdown.sessions", false);

    defaultPref("privacy.clearOnShutdown_v2.cache", false);
    defaultPref("privacy.clearOnShutdown_v2.cookiesAndStorage", false);

    defaultPref("privacy.clearHistory.browsingHistoryAndDownloads", false);
    defaultPref("privacy.clearHistory.cache", false);
    defaultPref("privacy.clearHistory.cookiesAndStorage", false);
    defaultPref("privacy.clearHistory.historyFormDataAndDownloads", false);
  '';

}
