#!/usr/bin/env bash
# LABYRINTH settings.
#   settings.sh                              menu (also: $mod+comma, right-click the eye in waybar)
#   settings.sh style glass|flat
#   settings.sh blur soft|medium|strong|<px>
#   settings.sh gaps none|tight|normal|wide|<px>
# Values live in ~/.config/labyrinth/settings; theme-apply.py bakes them into the configs.
S="$HOME/.config/sway/scripts"
CONF="$HOME/.config/labyrinth/settings"

get() { sed -n "s/^$1=//p" "$CONF" 2>/dev/null | tail -1; }
put() {
  mkdir -p "$(dirname "$CONF")"; touch "$CONF"
  { grep -v "^$1=" "$CONF"; echo "$1=$2"; } > "$CONF.tmp" && mv "$CONF.tmp" "$CONF"
}
apply() { "$S/theme.sh" reapply; }
menu()  { fuzzel --dmenu -p "$1" -w "${2:-34}" -l "${3:-8}"; }

blur_px() { case "$1" in soft) echo 5;; medium) echo 9;; strong) echo 14;; ""|*[!0-9]*) return 1;; *) echo "$1";; esac; }
gaps_px() { case "$1" in none) echo 0;; tight) echo 6;; normal) echo 14;; wide) echo 22;; ""|*[!0-9]*) return 1;; *) echo "$1";; esac; }

set_value() {  # key value
  local v
  case "$1" in
    style) [[ $2 == glass || $2 == flat ]] || { echo "style: glass|flat" >&2; exit 1; }; v=$2 ;;
    blur)  v=$(blur_px "$2") || { echo "blur: soft|medium|strong|<px>" >&2; exit 1; } ;;
    gaps)  v=$(gaps_px "$2") || { echo "gaps: none|tight|normal|wide|<px>" >&2; exit 1; } ;;
    *) echo "unknown setting: $1" >&2; exit 1 ;;
  esac
  put "$1" "$v"; apply
}

if [[ -n "$1" ]]; then set_value "$1" "$2"; exit; fi

theme=$(cat "$HOME/.config/labyrinth/current-theme" 2>/dev/null || echo labyrinth)
style=$(get style); style=${style:-glass}
blur=$(get blur);   blur=${blur:-9}
gaps=$(get gaps);   gaps=${gaps:-14}
sfx=$("$S/sfx.sh" status)
prof=$(powerprofilesctl get 2>/dev/null)
note=""; [[ $style == flat ]] && note="  (glass only)"

choice=$(printf '%s\n' \
  "◐ Theme     $theme" \
  "◧ Style     $style" \
  "◌ Blur      ${blur}px$note" \
  "▦ Gaps      ${gaps}px" \
  "♪ Sounds    $sfx" \
  "⚡ Power     ${prof:--}" \
  "? Keybinds" | menu '⚙ ' 36 7) || exit 0

case "$choice" in
  "◐"*) exec "$S/theme.sh" ;;
  "◧"*) pick=$(printf 'glass\nflat\n' | menu '◧ ' 20 2) && set_value style "$pick" ;;
  "◌"*) pick=$(printf 'soft\nmedium\nstrong\n' | menu '◌ ' 20 3) && set_value blur "$pick" ;;
  "▦"*) pick=$(printf 'none\ntight\nnormal\nwide\n' | menu '▦ ' 20 4) && set_value gaps "$pick" ;;
  "♪"*) exec "$S/sfx.sh" toggle ;;
  "⚡"*) pick=$(powerprofilesctl list | sed -nE 's/^[* ]+([a-z-]+):$/\1/p' | menu '⚡ ' 24 3) && powerprofilesctl set "$pick" ;;
  "?"*) exec "$S/keys.sh" ;;
esac
