{
  nixpkgs,
  # helix,
  ...
}:

nixpkgs.lib.composeManyExtensions [
  # helix.overlays.default

  # (import ./<name> ...)
  (import ./btop.nix)
  (import ./sesh.nix)
]
