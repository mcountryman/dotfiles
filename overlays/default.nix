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
  (import ./btop.nix)
  (import ./sesh.nix)
]
