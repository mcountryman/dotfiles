{
  me,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./language-hcl.nix
    ./language-js.nix
    ./language-nix.nix
    ./language-rust.nix
    ./language-template.nix
    ./language-toml.nix
    ./language-yaml.nix
    ./settings.nix
  ];

  environment.systemPackages = [
    #
    pkgs.bash-language-server

    (pkgs.vale.withStyles (s: [ s.google ]))
  ];

  home-manager.users.${me} = {
    programs.helix = {
      enable = true;
      languages = {
        language-server.spellcheck = {
          command = lib.getExe pkgs.vale-ls;
        };
      };
    };
  };
}
