#!/usr/bin/env bash
# Toggle the dropdown terminal; relaunch it if it was closed.
if ! swaymsg -t get_tree | grep -q '"app_id": "dropdown"'; then
  foot --app-id=dropdown >/dev/null 2>&1 &
  for _ in $(seq 40); do
    swaymsg -t get_tree | grep -q '"app_id": "dropdown"' && break
    sleep 0.05
  done
fi
swaymsg '[app_id="dropdown"] scratchpad show' >/dev/null
