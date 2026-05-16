{ lib, pkgs, ... }:
let
  inherit (lib) nameValuePair splitString;
  inherit (builtins)
    toJSON
    filter
    readFile
    listToAttrs
    ;

  base = {
    workdir.access = "readwrite";

    filesystem = {
      read = [
        # dotfiles
        "$HOME/Projects/dotfiles"
        # config
        "$HOME/.config/git"
      ];
      allow = [
        # tmp
        "/tmp"
        # agents
        "$HOME/.agents"
        "$HOME/.config/pi"
        "$HOME/.config/claude"
        # nodejs
        "$HOME/.cache/pnpm"
      ];
    };
  };

  # Packages `pi` is allowed to use (locked-down profile)
  allowedPackages = with pkgs; [
    cacert
    fd
    jq
    git
    bat
    ripgrep
  ];

  allowListClosure = pkgs.closureInfo { rootPaths = [ pkgs.llm-agents.pi ] ++ allowedPackages; };
  allowListPaths = filter (s: s != "") (
    splitString "\n" (readFile "${allowListClosure}/store-paths")
  );

  mkProfile =
    name: body:
    nameValuePair "nono/profiles/${name}.json" {
      text = toJSON ({ meta.name = name; } // body);
    };
in
{
  xdg.configFile = listToAttrs [
    (mkProfile "base" base)
    # Locked-down: only the explicit closure of pi + allowedPackages can be executed
    (mkProfile "pi" {
      extends = "base";
      filesystem.read = allowListPaths;
    })

    # Permissive: full /nix/store read access; use when pi needs to run nix tooling
    (mkProfile "pi-nix" {
      extends = "base";
      filesystem = {
        read = [ "/nix/store" ];
        allow = [
          "~/.cache/nix"
          "/nix/var/nix/daemon-socket" # Linux
          "/var/run/nix-daemon.socket" # Darwin
        ];
      };
    })

    (mkProfile "claude" {
      extends = [
        "claude-code"
        "base"
      ];
    })
  ];
}
