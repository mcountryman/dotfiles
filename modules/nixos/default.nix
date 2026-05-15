{ self, home-manager, ... }:
{
  imports = [
    (import ./home.nix { inherit self home-manager; })
    ../shared
  ];
}
