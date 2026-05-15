{ stylix, ... }@inputs:
{
  imports = [
    stylix.homeModules.stylix
    (import ../shared inputs)
  ];
}
