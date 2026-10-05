#!/usr/bin/env bash
grep '^bindsym' "$HOME/.config/sway/config" | sed 's/^bindsym //' | fuzzel --dmenu -p '? ' -w 80
