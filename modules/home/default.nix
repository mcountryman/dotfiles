{
  me,
  inputs,
  ...
}:
{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    {
      # home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "home-manager.bak";
      home-manager.users."${me}" = {
        imports = [ inputs.nur.modules.homeManager.default ];

        home.enableNixpkgsReleaseCheck = false; # until home-manager can handle nixpkgs 25.11
        home.homeDirectory = "/Users/${me}";

        # The state version is required and should stay at the version you
        # originally installed.
        home.stateVersion = "24.11";
      };
    }
    ./helix
    ./firefox
    ./alacritty.nix
    ./fish.nix
    ./zellij.nix
  ];
}
