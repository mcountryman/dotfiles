{
  nixpkgs,
  helix,
  llm-agents,
  ...
}:

nixpkgs.lib.composeManyExtensions [
  helix.overlays.default
  llm-agents.overlays.shared-nixpkgs
  (
    _final: prev:
    nixpkgs.lib.optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
      zellij = prev.stdenv.mkDerivation rec {
        pname = "zellij";
        version = "0.44.1";

        src = prev.fetchurl {
          url = "https://github.com/zellij-org/zellij/releases/download/v${version}/zellij-aarch64-apple-darwin.tar.gz";
          hash = "sha256-03635k0rj02jz5vp10dlb3rgijqx3h5yiwbyhx9cq3iz6nlijk2l=";
        };

        sourceRoot = ".";
        dontBuild = true;
        dontConfigure = true;

        installPhase = ''
          mkdir -p $out/bin
          cp zellij $out/bin/
          chmod +x $out/bin/zellij
        '';
      };
    }
  )
]
