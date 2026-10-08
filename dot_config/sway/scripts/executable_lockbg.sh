#!/usr/bin/env bash
# Lock background with live time. Run by swaylock-plugin; restarted each time it exits.
CACHE="$HOME/.cache/labyrinth"; BASE="$CACHE/lock-base.png"; SIZEF="$CACHE/lock-base.size"
FONT="$HOME/.local/share/fonts/UnifontExMono.ttf"
RT="${XDG_RUNTIME_DIR:-/tmp}/lockbg"; mkdir -p "$RT"
IM=magick; command -v magick >/dev/null 2>&1 || IM=convert

render() {  # $1 = "now" or "+1 minute"; prints image path
  local out="$RT/$(date -d "$1" +%H%M).png"
  [ -f "$out" ] && { echo "$out"; return; }
  read -r W H < <(tr 'x' ' ' < "$SIZEF"); local S=$((H / 1080)); [ "$S" -lt 1 ] && S=1
  $IM "$BASE" -stroke none -font "$FONT" -fill '#efe8cc' -gravity center \
    -pointsize $((160 * S)) -annotate +0-$((290 * S)) "$(date -d "$1" +%H:%M)" \
    -fill '#6f9f8b' -pointsize $((32 * S)) \
    -annotate +0-$((190 * S)) "$(date -d "$1" '+%A %d %B' | tr '[:lower:]' '[:upper:]')" \
    "$out.tmp.png" && mv "$out.tmp.png" "$out"
  echo "$out"
}

find "$RT" -name '*.png' -mmin +5 -delete
swaybg -i "$(render now)" -m fill &
pid=$!
render "+1 minute" >/dev/null          # pre-render next minute so the swap is instant
sleep $((60 - 10#$(date +%S)))
kill $pid; wait $pid 2>/dev/null
