#!/usr/bin/env bash
# Cycle power-profiles-daemon profiles.
out=$(powerprofilesctl list)
mapfile -t p < <(sed -nE 's/^[* ]+([a-z-]+):$/\1/p' <<< "$out")
cur=$(sed -nE 's/^\* ([a-z-]+):$/\1/p' <<< "$out")
next="${p[0]}"
for i in "${!p[@]}"; do
  [ "${p[$i]}" = "$cur" ] && next="${p[$(( (i + 1) % ${#p[@]} ))]}"
done
powerprofilesctl set "$next"
command -v notify-send >/dev/null && notify-send -t 1500 "Power profile" "$next" &
