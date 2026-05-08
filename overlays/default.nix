{
  nixpkgs,
  # helix,
  llm-agents,
  ...
}:

nixpkgs.lib.composeManyExtensions [
  # helix.overlays.default
  llm-agents.overlays.default

  # (import ./<name> ...)
  (import ./sesh.nix)
]
