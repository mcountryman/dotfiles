# dotfiles

My `nixos`/`darwin-nix` configurations.

## Structure

- `hosts/<host>/users/<user>` - Per-host, per-user configuration
- `modules/shared` - Things shared between `nixos` and `darwin-nix`
- `modules/darwin` - Things only for `darwin-nix`
- `modules/nixos` - Things only for `nixos`
- `modules/home/shared` - Shared home-manager config
- `modules/home/darwin` - Darwin-only home-manager config
- `modules/home/nixos` - NixOS-only home-manager config
- `overlays` - Nixpkgs overlays