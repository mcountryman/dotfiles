# dotfiles

My `nixos`/`darwin-nix` configurations.

## Structure

- `hosts/*` - Per-host configuration

- `modules/common` - Things shared between `nixos`, `darwin-nix` systems
- `modules/darwin` - Things only for `darwin-nix`
- `modules/nixos` - Things only for `nixos`
- `modules/home/per-user` - Home configurations for everyone

- `overlays` - Overlays.

## Future

- [ ] Move arbitrarily installed macos apps to nix config
  - [ ] WhatsApp
  - [ ] Signal
  - [ ] Other..
- [ ] Yeet `rustup` from `PATH` to allow for project specific rust installations
  - This should make it easier to make dev environments repeatable
- [ ] Make `helix` + `yazi` play nicely
- [ ] Make `yabai` active window borders not look shitty when using native macos
      window drag
- [ ] Fix `yabai` rules to handle `WhatsApp` and friends
- [ ] Figure out how to handle duplicate flake inputs when used as a module
- [ ] Figure out how to pass flake inputs to modules without circular-ref errs
- [ ] Single user configurations if it arises