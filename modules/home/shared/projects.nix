{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) getExe;

  self = ../../../.;
  projects = "${config.home.homeDirectory}/Projects";
  bootstrap = pkgs.writeShellScriptBin "bootstrap" ''
    # bootstrap
    #
    # Setup ~/Projects/dotfiles to track the remote repo and clean-up bootstrap
    # file(s).
    cd "${projects}/dotfiles"

    # Avoid overwritting local changes
    if ! diff -rq --exclude=".git" --exclude="bootstrap" "${self}" "." >/dev/null 2>&1; then
      echo "dotfiles differs from flake, aborting" >&2
      exit 1
    fi

    # Don't do it twice
    if [ -d .git ]; then
      echo "dotfiles attached to git manually, aborting" >&2
      exit 1
    fi

    ${getExe pkgs.git} init
    ${getExe pkgs.git} remote add origin git@github.com:mcountryman/dotfiles.git
    ${getExe pkgs.git} remote add origin-http https://github.com/mcountryman/dotfiles.git

    # Try `origin`, fallback to `origin-http`
    if ${getExe pkgs.git} fetch --depth=1 origin 2>/dev/null; then
      ${getExe pkgs.git} reset --hard FETCH_HEAD
      ${getExe pkgs.git} branch --set-upstream-to=origin/main main
    else
      ${getExe pkgs.git} fetch --depth=1 origin-http
      ${getExe pkgs.git} reset --hard FETCH_HEAD
      ${getExe pkgs.git} branch --set-upstream-to=origin-http/main main
    fi

    rm -f bootstrap
  '';
in
{
  home.activation.bootstrapProjects = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    echo "Activating ~/Projects"

    mkdir -p "${projects}"
    mkdir -p "${projects}/dotfiles"

    # Overwrite `dotfiles` with flake contents
    if [ ! -d "${projects}/dotfiles/.git" ]; then
      echo "Activating ~/Projects/dotfiles"

      ${pkgs.rsync}/bin/rsync -a --delete "${self}/" "${projects}/dotfiles/"
      chmod -R u+rw "${projects}/dotfiles/"
      cp "${getExe bootstrap}" "${projects}/dotfiles/bootstrap"
    fi
  '';
}
