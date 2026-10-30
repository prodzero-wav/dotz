#!/usr/bin/env bash
grep -h '^bindsym' "$HOME/.config/sway/config" "$HOME/.config/sway/conf.d/"*.conf 2>/dev/null \
  | sed 's/^bindsym //' | fuzzel --dmenu -p '? ' -w 80
