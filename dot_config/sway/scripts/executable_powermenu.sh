#!/usr/bin/env bash
choice=$(printf 'Lock\nSuspend\nLog out\nReboot\nShutdown\n' | fuzzel --dmenu -p '⏻ ' -w 24 -l 5)
case "$choice" in
  Lock) ~/.config/sway/scripts/lock.sh ;;
  Suspend) systemctl suspend ;;
  "Log out") swaymsg exit ;;
  Reboot) ~/.config/sway/scripts/sfx.sh shutdown --wait; systemctl reboot ;;
  Shutdown) ~/.config/sway/scripts/sfx.sh shutdown --wait; systemctl poweroff ;;
esac
