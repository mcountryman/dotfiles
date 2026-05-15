{ self, home-manager }:
{
  imports = [ home-manager.nixosModules.home-manager ];

  home-manager = {
    useGlobalPkgs = true;
    backupFileExtension = "home-manager.bak";
    sharedModules = [ self.homeModules.nixos ];
    users.marvin.imports = [ self.homeModules.users.marvin ];
  };
}
