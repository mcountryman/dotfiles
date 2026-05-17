## Sandbox Permissions (nono)

Pi runs inside a [nono](https://nono.sh) capability-based sandbox. Filesystem
access is as follows:

### Read + Write (`--allow`)

| Path               | Notes                                                                                 |
| ------------------ | ------------------------------------------------------------------------------------- |
| `$PWD`             | Current working directory at launch time — changes with each invocation               |
| `/tmp`             | Temporary files                                                                       |
| `~/.agents`        | Agent config/data (symlink → `~/Projects/dotfiles/modules/home/shared/agents/agents`) |
| `~/.pi`            | Pi config (symlink → `~/Projects/dotfiles/modules/home/shared/agents/pi`)             |
| `~/.pi/notify`     | Notification bridge file — pi extension writes, systemd forwarder reads & truncates  |
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