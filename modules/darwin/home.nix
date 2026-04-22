{ self, home-manager }:
{
  imports = [ home-manager.darwinModules.home-manager ];

  home-manager = {
    useGlobalPkgs = true;
    backupFileExtension = "home-manager.bak";
    sharedModules = [ self.homeModules.darwin ];
    users.marvin.imports = [ self.homeModules.users.marvin ];
  };
}
