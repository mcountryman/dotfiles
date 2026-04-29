# zellij-session-switcher.nu — interactive zellij session switcher
#
# Lists zellij sessions sorted by creation time (newest first),
# opens fzf for selection, and switches to the chosen session.
# Exits cleanly on Ctrl-C/Escape with no session change.

# Get all zellij sessions sorted by creation time (newest first)
let raw_sessions = (zellij list-sessions --no-formatting --reverse)

# Exit early if there are no sessions at all
if ($raw_sessions | is-empty) {
    exit 0
}

# Parse session names from lines like:
#   session-name [Created 2h 30m ago]
#   session-name [Created 2h 30m ago] (current)
let sessions = (
    $raw_sessions
    | lines
    | parse --regex '(?P<name>\S+)\s+\[Created'
    | get name
    | where { $in != $env.ZELLIJ_SESSION_NAME }
)

# Exit if only the current session exists (nothing to switch to)
if ($sessions | is-empty) {
    exit 0
}

# Present sessions via fzf and capture selection
let selection = (
    $sessions
    | str join "\n"
    | fzf --height 10 --reverse --no-multi --prompt "session> "
)

# fzf returns empty on Ctrl-C/Escape — exit cleanly
if ($selection | is-empty) {
    exit 0
}

# Switch to the selected session
zellij switch-session $selection
