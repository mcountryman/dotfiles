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

}
