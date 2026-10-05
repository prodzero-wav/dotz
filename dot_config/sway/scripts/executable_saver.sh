#!/usr/bin/env bash
case "$1" in
  start) pgrep -f 'app-id=mazesaver' >/dev/null || foot --fullscreen --app-id=mazesaver python3 "$HOME/.config/sway/scripts/mazesaver.py" & ;;
  stop)  pkill -f 'app-id=mazesaver' ;;
esac
