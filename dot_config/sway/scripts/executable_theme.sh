#!/usr/bin/env bash
# Theme selector. Usage: theme.sh [name]   (no arg = menu; "reapply" = redo current theme, e.g. after chezmoi apply)
S="$HOME/.config/sway/scripts"
TD="$HOME/.config/labyrinth/themes"
CUR=$(cat "$HOME/.config/labyrinth/current-theme" 2>/dev/null || echo labyrinth)

pick="$1"
if [[ -z "$pick" ]]; then
  list=$(for f in "$TD"/*.map; do n=$(basename "$f" .map); [[ $n == "$CUR" ]] && echo "● $n" || echo "  $n"; done)
  pick=$(printf '%s\n' "$list" | fuzzel --dmenu -p '◐ ' -w 30 -l 6) || exit 0
  pick=$(sed -E 's/^[● ] +//' <<<"$pick")
  [[ -z "$pick" ]] && exit 0
fi
[[ "$pick" == reapply ]] && pick=$CUR

out=$(python3 "$S/theme-apply.py" "$pick" 2>&1) || { notify-send -u critical "Theme" "$out"; exit 1; }

rm -f "$HOME/.cache/labyrinth/lock-base."* "${XDG_RUNTIME_DIR:-/tmp}"/lockbg/*.png
swaymsg reload >/dev/null   # sway restarts waybar itself (swaybar_command)
sleep 1.5; pgrep -x waybar >/dev/null || setsid -f waybar >/dev/null 2>&1
makoctl reload 2>/dev/null
pkill -f borderglow.py; setsid -f "$S/borderglow.py" >/dev/null 2>&1
pkill swayosd-server; setsid -f swayosd-server >/dev/null 2>&1
setsid -f "$S/lock.sh" prepare >/dev/null 2>&1
notify-send "Theme" "$pick applied. New terminals/apps pick it up."
