## Pi Configuration

- Pi config directory is `~/.config/pi` (not `~/.pi`)
- Global settings: `~/.config/pi/settings.json`
- Keybindings: `~/.config/pi/agent/keybindings.json`
- Skills: `~/.config/pi/skills/`
- Extensions: `~/.config/pi/extensions/`

## Sandbox Permissions (nono)

Pi runs inside a [nono](https://nono.sh) capability-based sandbox. Filesystem
access is as follows:

### Read + Write (`--allow`)

| Path               | Notes                                                                                 |
| ------------------ | ------------------------------------------------------------------------------------- |
| `$PWD`             | Current working directory at launch time — changes with each invocation               |
| `/tmp`             | Temporary files                                                                       |
| `~/.agents`        | Agent config/data (symlink → `~/Projects/dotfiles/modules/home/shared/agents/agents`) |
| `~/.config/pi`     | Pi config (symlink → `~/Projects/dotfiles/modules/home/shared/agents/pi`)             |
| `~/.config/claude` | Claude config (symlink → `~/Projects/dotfiles/modules/home/shared/agents/claude`)     |

### Read-only (`--read`)

| Path                  | Notes                                              |
| --------------------- | -------------------------------------------------- |
| `/nix`                | Nix store and var — binaries, libraries            |
| `~/Projects/dotfiles` | Dotfiles repo — readable but not writable directly |
| `~/.cache/pnpm`       | pnpm package cache                                 |

### Not accessible

Everything else outside the above paths is denied by default, including the rest
of `~`.
