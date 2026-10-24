#!/usr/bin/env bash
# Plays the current theme's `wallpaper video <path>` (if any) with mpvpaper; stops it otherwise.
CFG="$HOME/.config/labyrinth"
cur=$(cat "$CFG/current-theme" 2>/dev/null || echo labyrinth)
vid=$(awk '$1=="wallpaper" && $2=="video" {print $3; exit}' "$CFG/themes/$cur.map" 2>/dev/null)
vid="${vid/#\~/$HOME}"
pkill -x mpvpaper 2>/dev/null
[[ -n $vid && -f $vid ]] || exit 0
command -v mpvpaper >/dev/null || exit 0
exec setsid -f mpvpaper -p -o "no-audio loop hwdec=auto panscan=1.0" '*' "$vid" >/dev/null 2>&1
