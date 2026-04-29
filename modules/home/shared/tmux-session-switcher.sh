#!/bin/sh
# tmux-session-switcher — interactive session switcher using fzf
# Lists tmux sessions, opens fzf for selection, switches to the chosen session.
# Exits cleanly on Escape/Ctrl-C (fzf returns empty).

session=$(tmux list-sessions 2>/dev/null | cut -d: -f1 | fzf --reverse --no-multi --prompt="session> ")

if [ -n "$session" ]; then
    tmux switch-client -t "$session"
fi