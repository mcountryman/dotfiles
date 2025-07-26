{ lib, config, ... }:
let
  inherit (lib) types mkOption;

  cfg = config.dotfiles;
  user =
    { name, ... }:
    {
      options = {
        name = mkOption {
          type = types.str;
          default = name;
          description = "The name of the user";
        };

        email = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "The email of the user";
        };

        fullName = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "The full name of the user";
        };

        primary = mkOption {
          type = types.bool;
          default = false;
          description = "Whether the user is the primary user or not.";
        };
      };
    };
in
{
  options.dotfiles = {
    users = mkOption {
      type = types.attrsOf (types.submodule user);
      default = [ ];
      description = "The list of users that will be effected by this module.";
    };

    headless = mkOption {
      type = types.bool;
      default = true;
      description = "Determines if the system environment needs a GUI or not.";
    };
  };

  config = { };
}
