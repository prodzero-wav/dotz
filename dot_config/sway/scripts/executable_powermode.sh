#!/usr/bin/env bash
# Battery: power-saver profile, ~60Hz.  AC: balanced profile, max refresh.  The border pulse stays on in both.
# Set KEEP_BLUR=0 to also turn off blur + shadows on battery (saves more GPU power, looks flatter).
KEEP_BLUR=1
PS="${POWER_SUPPLY_DIR:-/sys/class/power_supply}"

ls "$PS"/BAT* >/dev/null 2>&1 || exit 0   # no battery (desktop): nothing to do

set_rate() {  # $1 = high | low
  python3 - "$1" << 'PY'
import json, subprocess, sys
mode = sys.argv[1]
outs = json.loads(subprocess.check_output(["swaymsg", "-r", "-t", "get_outputs"]))
for o in outs:
    if not o.get("active"):
        continue
    cur = o["current_mode"]
    cands = [m for m in o["modes"] if m["width"] == cur["width"] and m["height"] == cur["height"]]
    if mode == "high":
        pick = max(cands, key=lambda m: m["refresh"])
    else:
        pick = min(cands, key=lambda m: abs(m["refresh"] - 60000))
    subprocess.call(["swaymsg", "output", o["name"], "mode", "%dx%d@%.3fHz" % (pick["width"], pick["height"], pick["refresh"] / 1000)])
PY
}

apply() {  # $1 = 1 (AC) | 0 (battery)
  if [ "$1" = 1 ]; then
    powerprofilesctl set balanced 2>/dev/null
    set_rate high
    swaymsg "blur enable; shadows enable" >/dev/null
  else
    powerprofilesctl set power-saver 2>/dev/null
    set_rate low
    [ "$KEEP_BLUR" = 0 ] && swaymsg "blur disable; shadows disable" >/dev/null
  fi
}

last=""
while true; do
  ac=0
  for d in "$PS"/*; do
    [ "$(cat "$d/type" 2>/dev/null)" = Mains ] && [ "$(cat "$d/online" 2>/dev/null)" = 1 ] && ac=1
  done
  if [ "$ac" != "$last" ]; then
    apply "$ac"
    last="$ac"
  fi
  [ -n "$ONCE" ] && exit 0
  sleep 15
done
