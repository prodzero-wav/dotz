#!/usr/bin/env bash
choice=$(printf 'Lock\nSuspend\nLog out\nReboot\nShutdown\n' | fuzzel --dmenu -p '⏻ ' -w 24 -l 5)
bye() { ~/.config/sway/scripts/sfx.sh shutdown --wait & foot --fullscreen --app-id=shutdown python3 ~/.config/sway/scripts/shutdown-anim.py; wait; }
case "$choice" in
  Lock) ~/.config/sway/scripts/lock.sh ;;
  Suspend) systemctl suspend ;;
  "Log out") swaymsg exit ;;
  Reboot) bye; systemctl reboot ;;
  Shutdown) bye; systemctl poweroff ;;
esac
