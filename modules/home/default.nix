{
  me,
  inputs,
  ...
}:
{
  imports = [
    {
      # home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "home-manager.bak";
      home-manager.users."${me}" = {
        imports = [
          inputs.nur.modules.homeManager.default
        ];

        home.homeDirectory = "/Users/${me}";
        # until home-manager can handle nixpkgs 25.11
        home.enableNixpkgsReleaseCheck = false;

        # The state version is required and should stay at the version you
        # originally installed.
        home.stateVersion = "24.11";
      };
    }
    ./git.nix
    ./helix
    ./firefox
    ./alacritty.nix
    ./fish.nix
    ./yazi.nix
    ./zellij.nix
  ];
}
