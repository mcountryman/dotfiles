# AGENTS.md

My dotfiles configuration. Made to be portable, modular, and consumable.

# Run

- `fairy` - `sudo darwin-rebuild switch --flake .#`

# Test

- `nix fmt` - Verify nix style
- `nix flake check` - Verify lints pass

## Structure

- `hosts/<host>/users/<user>` - User specific home configuration for a host
- `modules/nixos` - Nixos only configuration
- `modules/darwin` - Darwin only configuration
- `modules/shared` - Nixos + Darwin shared configuration
- `modules/home/nixos` - Nixos only home configuration
- `modules/home/darwin` - Darwin only home configuration
- `modules/home/shared` - Nixos + Darwin home configuration
- `modules/home/users/<user>` - Nixos + Darwin user specific home configuration
- `overlays/` - Nixpkgs overlays
  - When writing a package overlay, ensure it lives in it's own file

## Contributing

When making modifications:

- _DO_ run `nix flake check`
- _DO_ run `nix fmt`

When committing:

- _DO_ provide a clear subject line
- _DO_ follow the format `<scope>: <brief desc>` when writing subject lines
- _DO_ provide detailed breakdown
- _DONT_ use conventional commmit

## Notes

- _DONT_ make changes that breaks nixos/darwin portability
- _DONT_ forget to make sure to put configurations in the proper directory
