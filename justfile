
# Switch the system profile
switch profile="": (_activate "switch" profile)

# Run flake checks
check:
    nix flake check --all-systems

# Run darwin-nix activator
[macos]
_activate kind profile="":
    darwin-rebuild {{ kind }} --flake ".#{{ profile }}"

# Run nixos activator
[linux]
_activate kind profile="":
    nixos-rebuild {{ kind }} --flake ".#{{ profile }}"
