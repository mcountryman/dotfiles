{
  me,
  lib,
  pkgs,
  ...
}: {
  environment.systemPackages = [
    pkgs.terraform-ls
  ];

  home-manager.users.${me}.programs.helix.languages = {
    language = [
      {
        name = "hcl";
        auto-format = true;
        formatter = {
          command = lib.getExe pkgs.opentofu;
          args = ["fmt" "-"];
        };
      }
    ];
  };
}
