#!/usr/bin/env bash
# Focus the app if it's open; otherwise launch it, ignoring key spam while it starts.
id="$1"; shift
if swaymsg -t get_tree | grep -q "\"app_id\": \"$id\""; then
  swaymsg "[app_id=\"$id\"] focus" > /dev/null
else
  exec 9> "/tmp/focusorlaunch-$id.lock"
  flock -n 9 || exit 0
  "$@" 9>&- > /dev/null 2>&1 &
  sleep 4
fi
