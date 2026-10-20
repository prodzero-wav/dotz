#!/usr/bin/env bash
# Wi-Fi selector (fuzzel + nmcli)
F=(fuzzel --dmenu -w 44)

wifi=$(nmcli -t -f WIFI radio)
if [[ "$wifi" != enabled ]]; then
  c=$(printf 'Turn Wi-Fi on\n' | "${F[@]}" -p '󰖪 ' -l 1)
  [[ "$c" == "Turn Wi-Fi on" ]] && { nmcli radio wifi on || notify-send -u critical "Wi-Fi" "Couldn't turn on"; }
  exit 0
fi

nmcli device wifi rescan >/dev/null 2>&1
list=$(nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY,BSSID device wifi list --rescan no \
  | awk -F: '$2!=""{
      bssid=$5; for(i=6;i<=NF;i++) bssid=bssid":"$i
      sec=($4==""?"open":$4)
      if(!seen[$2]++ || $1=="*") printf "%s %-28s %3s%%  %s\n", ($1=="*"?"●":" "), $2, $3, sec
    }' | sort -t'%' -k1,1 -u | sort -k3 -nr)

menu=$(printf '%s\n󰑓 Rescan\n󰖪 Wi-Fi off\n󰅖 Disconnect\n󰒓 Advanced (nmtui)' "$list")
choice=$(printf '%s\n' "$menu" | "${F[@]}" -p '󰖩 ' -l 12) || exit 0
[[ -z "$choice" ]] && exit 0

case "$choice" in
  *Rescan) exec "$0" ;;
  *"Wi-Fi off") nmcli radio wifi off; notify-send "Wi-Fi" "Off" ;;
  *Disconnect) nmcli device disconnect "$(nmcli -t -f DEVICE,TYPE device | awk -F: '$2=="wifi"{print $1; exit}')" ;;
  *nmtui) foot nmtui ;;
  *)
    ssid=$(sed -E 's/^[● ] //; s/ +[0-9]+%.*$//' <<<"$choice")
    sec=$(awk '{print $NF}' <<<"$choice")
    if nmcli -t -f NAME connection show | grep -qxF "$ssid"; then
      out=$(nmcli connection up id "$ssid" 2>&1)
    elif [[ "$sec" == open ]]; then
      out=$(nmcli device wifi connect "$ssid" 2>&1)
    else
      pw=$(fuzzel --dmenu --password -p "󰌾 $ssid " -l 0 -w 44 </dev/null) || exit 0
      out=$(nmcli device wifi connect "$ssid" password "$pw" 2>&1)
    fi
    if [[ $? -eq 0 ]]; then notify-send "Wi-Fi" "Connected to $ssid"
    else notify-send -u critical "Wi-Fi" "Failed: $ssid\n${out:0:120}"; fi
    ;;
esac
