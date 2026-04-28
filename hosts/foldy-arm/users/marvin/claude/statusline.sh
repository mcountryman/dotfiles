#!/usr/bin/env bash
# Claude Code powerline statusline
# Segments: model | agent | cost | context% | 5h% | duration
# Style: powerline arrows, nerd-font glyphs, gruvbox-dark-hard colors

input=$(cat)

# --- Parse JSON fields ---
MODEL_NAME=$(printf '%s' "$input" | jq -r '.model.display_name // ""')
AGENT_NAME=$(printf '%s' "$input" | jq -r '.agent.name // ""')
TOTAL_COST=$(printf '%s' "$input" | jq -r '.cost.total_cost_usd // ""')
DURATION_MS=$(printf '%s' "$input" | jq -r '.cost.total_duration_ms // ""')
CTX_PCT=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // ""')
FIVE_HOUR_PCT=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.used_percentage // ""')

# --- Color palette (gruvbox-dark-hard) ---
FG_HEX="#1d2021"
BG_MODEL="#458588"
BG_AGENT="#b16286"
BG_COST="#98971a"
BG_DURATION="#504945"
THRESH_GREEN="#98971a"
THRESH_YELLOW="#d79921"
THRESH_RED="#cc241d"

RESET=$'\033[0m'

# --- hex_to_rgb: #RRGGBB -> "R G B" ---
hex_to_rgb() {
  local hex="${1#\#}"
  printf '%d %d %d' \
    "$(( 16#${hex:0:2} ))" \
    "$(( 16#${hex:2:2} ))" \
    "$(( 16#${hex:4:2} ))"
}

# emit ANSI 24-bit background escape
bg_esc() {
  local r g b
  read -r r g b <<< "$(hex_to_rgb "$1")"
  printf '\033[48;2;%d;%d;%dm' "$r" "$g" "$b"
}

# emit ANSI 24-bit foreground escape
fg_esc() {
  local r g b
  read -r r g b <<< "$(hex_to_rgb "$1")"
  printf '\033[38;2;%d;%d;%dm' "$r" "$g" "$b"
}

# --- Powerline state ---
prev_bg=""

# seg <text> <bg_hex>
# Prints the powerline arrow transition then the segment body.
# Tracks prev_bg globally so the next call (or the finale) can close it.
seg() {
  local text="$1"
  local new_bg="$2"

  if [ -n "$prev_bg" ]; then
    # Arrow: fg=prev_bg over new_bg background
    printf '%s%s%s' "$(bg_esc "$new_bg")" "$(fg_esc "$prev_bg")" ""
  else
    # First segment: no leading arrow, just start the background
    printf '%s' "$(bg_esc "$new_bg")"
  fi

  # Segment body
  printf '%s %s ' "$(fg_esc "$FG_HEX")" "$text"

  prev_bg="$new_bg"
}

# --- Threshold color for percentages ---
pct_color() {
  local pct="$1"
  if awk "BEGIN { exit !($pct > 80) }"; then
    printf '%s' "$THRESH_RED"
  elif awk "BEGIN { exit !($pct >= 50) }"; then
    printf '%s' "$THRESH_YELLOW"
  else
    printf '%s' "$THRESH_GREEN"
  fi
}

# --- Format duration from milliseconds ---
format_duration() {
  local ms="$1"
  local total_sec
  total_sec=$(awk "BEGIN { printf \"%d\", $ms / 1000 }")
  local hours=$(( total_sec / 3600 ))
  local mins=$(( (total_sec % 3600) / 60 ))
  local secs=$(( total_sec % 60 ))

  if [ "$hours" -gt 0 ]; then
    printf '%dh %dm' "$hours" "$mins"
  elif [ "$mins" -gt 0 ]; then
    printf '%dm%ds' "$mins" "$secs"
  else
    printf '%ds' "$secs"
  fi
}

# --- Segment 1: Model (always) ---
if [ -n "$MODEL_NAME" ] && [ "$MODEL_NAME" != "null" ]; then
  seg " $MODEL_NAME" "$BG_MODEL"
fi

# --- Segment 2: Agent (omit if absent) ---
if [ -n "$AGENT_NAME" ] && [ "$AGENT_NAME" != "null" ] && [ "$AGENT_NAME" != "" ]; then
  seg " $AGENT_NAME" "$BG_AGENT"
fi

# --- Segment 3: Cost ---
if [ -n "$TOTAL_COST" ] && [ "$TOTAL_COST" != "null" ] && [ "$TOTAL_COST" != "" ]; then
  cost_fmt=$(awk "BEGIN { printf \"\$%.2f\", $TOTAL_COST }")
  seg " $cost_fmt" "$BG_COST"
fi

# --- Segment 4: Context window % (color by threshold) ---
if [ -n "$CTX_PCT" ] && [ "$CTX_PCT" != "null" ] && [ "$CTX_PCT" != "" ]; then
  ctx_color=$(pct_color "$CTX_PCT")
  ctx_int=$(awk "BEGIN { printf \"%d\", $CTX_PCT }")
  seg " ctx ${ctx_int}%" "$ctx_color"
fi

# --- Segment 5: 5-hour rate limit % (omit if absent; color by threshold) ---
if [ -n "$FIVE_HOUR_PCT" ] && [ "$FIVE_HOUR_PCT" != "null" ] && [ "$FIVE_HOUR_PCT" != "" ]; then
  fh_color=$(pct_color "$FIVE_HOUR_PCT")
  fh_int=$(awk "BEGIN { printf \"%d\", $FIVE_HOUR_PCT }")
  seg " 5h ${fh_int}%" "$fh_color"
fi

# --- Segment 6: Duration ---
if [ -n "$DURATION_MS" ] && [ "$DURATION_MS" != "null" ] && [ "$DURATION_MS" != "" ]; then
  dur_str=$(format_duration "$DURATION_MS")
  seg " $dur_str" "$BG_DURATION"
fi

# --- Trailing powerline arrow: reset bg, fg = last segment color ---
if [ -n "$prev_bg" ]; then
  printf '%s%s%s\n' "$RESET" "$(fg_esc "$prev_bg")" "$RESET"
else
  printf '\n'
fi
