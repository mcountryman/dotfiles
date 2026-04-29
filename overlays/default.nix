{
  nixpkgs,
  helix,
  llm-agents,
  ...
}:

nixpkgs.lib.composeManyExtensions [
  helix.overlays.default
  llm-agents.overlays.shared-nixpkgs
  (_final: prev: {
    zellij = prev.zellij.overrideAttrs (_old: rec {
      version = "0.44.1";
      src = prev.fetchFromGitHub {
        owner = "zellij-org";
        repo = "zellij";
        rev = "v${version}";
        hash = "sha256-KHpVUjuOmMtkt8qBaCozD3M44eEtDwFmdDfszKAz0bM=";
      };
      cargoHash = "";
      cargoLock.lockFile = "${src}/Cargo.lock";
    });
  })
]
