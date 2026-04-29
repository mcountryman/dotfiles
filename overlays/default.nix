{
  nixpkgs,
  helix,
  llm-agents,
  ...
}:

nixpkgs.lib.composeManyExtensions [
  helix.overlays.default
  llm-agents.overlays.shared-nixpkgs
  (_final: prev: import ./zellij.nix prev)
]
