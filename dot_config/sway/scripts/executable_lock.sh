#!/usr/bin/env bash
# Usage: lock.sh          lock the screen
#        lock.sh prepare  (re)build the cached background if needed
WALL="$HOME/Pictures/wallpapers/labyrinth.jpg"
CACHE="$HOME/.cache/labyrinth"
BASE="$CACHE/lock-base.png"
SIZEF="$CACHE/lock-base.size"
IM=magick
command -v magick >/dev/null 2>&1 || IM=convert
mkdir -p "$CACHE"

prepare() {
  read -r W H < <(swaymsg -t get_outputs 2>/dev/null | python3 -c 'import json,sys; o=json.load(sys.stdin); m=next((x for x in o if x.get("focused")), o[0])["current_mode"]; print(m["width"], m["height"])' 2>/dev/null) || true
  W=${W:-1920}; H=${H:-1080}
  if [ -f "$BASE" ] && [ -f "$SIZEF" ] && [ "$(cat "$SIZEF")" = "${W}x${H}" ] && [ ! "$WALL" -nt "$BASE" ]; then
    return 0
  fi
  local S=$((H / 1080)); [ "$S" -lt 1 ] && S=1
  $IM "$WALL" -resize "${W}x${H}^" -gravity center -extent "${W}x${H}" \
    -blur 0x8 -fill black -colorize 40% \
    -background black -vignette 0x$((150 * S)) \
    -fill none -stroke 'rgba(212,203,168,0.35)' -strokewidth $((2 * S)) \
    -draw "rectangle $((40 * S)),$((40 * S)) $((W - 40 * S - 1)),$((H - 40 * S - 1))" \
    "$BASE" && echo "${W}x${H}" > "$SIZEF"
}

if [ "$1" = "prepare" ]; then
  prepare
  exit 0
fi

pgrep -x swaylock-plugin >/dev/null && exit 0
[ -f "$BASE" ] || prepare

exec swaylock-plugin -f --command "$HOME/.config/sway/scripts/lockbg.sh"
