#!/usr/bin/env bash
# LABYRINTH UI sounds.
#   sfx.sh <startup|shutdown|info|error> [--wait]   play a sound (silent when muted)
#   sfx.sh toggle|mute|unmute|status                 control the mute flag
DIR="$HOME/.config/labyrinth/sounds"
FLAG="${XDG_STATE_HOME:-$HOME/.local/state}/labyrinth/sfx-muted"

case "$1" in
  toggle) [[ -e "$FLAG" ]] && exec "$0" unmute || exec "$0" mute ;;
  mute)   mkdir -p "$(dirname "$FLAG")"; touch "$FLAG"; notify-send -u low "Sounds" "Muted"; exit 0 ;;
  unmute) rm -f "$FLAG"; notify-send "Sounds" "On"; exit 0 ;;
  status) [[ -e "$FLAG" ]] && echo muted || echo on; exit 0 ;;
esac

[[ -e "$FLAG" ]] && exit 0
file="$DIR/$1.wav"
[[ -f "$file" ]] || exit 1

if command -v pw-play >/dev/null; then player=(pw-play)
elif command -v paplay >/dev/null; then player=(paplay)
else exit 1; fi

if [[ "$2" == "--wait" ]]; then
  "${player[@]}" "$file"
else
  "${player[@]}" "$file" >/dev/null 2>&1 &
fi
