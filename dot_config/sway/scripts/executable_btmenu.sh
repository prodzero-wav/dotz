#!/usr/bin/env bash
# Bluetooth selector (fuzzel + bluetoothctl)
F=(fuzzel --dmenu -w 44)

if ! bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
  c=$(printf 'Turn Bluetooth on\n' | "${F[@]}" -p '󰂲 ' -l 1) || exit 0
  [[ "$c" == "Turn Bluetooth on" ]] && { rfkill unblock bluetooth; bluetoothctl power on >/dev/null || notify-send -u critical "Bluetooth" "Couldn't turn on"; }
  exit 0
fi

scan() {
  notify-send "Bluetooth" "Scanning for 6s…"
  bluetoothctl --timeout 6 scan on >/dev/null 2>&1
}

devices() {
  bluetoothctl devices | while read -r _ mac name; do
    info=$(bluetoothctl info "$mac")
    if grep -q "Connected: yes" <<<"$info"; then mark="●"
    elif grep -q "Paired: yes" <<<"$info"; then mark="○"
    else mark="+"; fi
    printf '%s %s  [%s]\n' "$mark" "$name" "$mac"
  done | sort
}

[[ "$1" == scan ]] && scan
choice=$({ devices; printf '󰑓 Scan\n󰂲 Bluetooth off\n󰒓 Advanced (bluetoothctl)\n'; } | "${F[@]}" -p '󰂯 ' -l 12) || exit 0
[[ -z "$choice" ]] && exit 0

case "$choice" in
  *Scan) exec "$0" scan ;;
  *"Bluetooth off") bluetoothctl power off >/dev/null; notify-send "Bluetooth" "Off" ;;
  *Advanced*) foot bluetoothctl ;;
  *)
    mac=$(grep -oE '([0-9A-F]{2}:){5}[0-9A-F]{2}' <<<"$choice")
    name=$(sed -E 's/^. //; s/  \[.*$//' <<<"$choice")
    if bluetoothctl info "$mac" | grep -q "Connected: yes"; then
      bluetoothctl disconnect "$mac" >/dev/null && notify-send "Bluetooth" "Disconnected $name"
    else
      bluetoothctl info "$mac" | grep -q "Paired: yes" || { bluetoothctl pair "$mac" >/dev/null || { notify-send -u critical "Bluetooth" "Pairing failed: $name"; exit 1; }; bluetoothctl trust "$mac" >/dev/null; }
      if bluetoothctl connect "$mac" >/dev/null 2>&1; then notify-send "Bluetooth" "Connected to $name"
      else notify-send -u critical "Bluetooth" "Failed to connect to $name"; fi
    fi
    ;;
esac
