#!/usr/bin/env bash
# network-menu.sh — wofi wifi picker using nmcli
# Click an active connection to disconnect; click an available one to connect.

WOFI_ARGS="--dmenu --insensitive --prompt=Network --width=320 --lines=10"

# Rescan in background
nmcli device wifi rescan 2>/dev/null &

# Build list: connected first, then available (deduplicated)
CONNECTED=$(nmcli -t -f active,ssid device wifi | grep '^yes:' | sed 's/^yes:/✔  /' | sort -u)
AVAILABLE=$(nmcli -t -f active,ssid device wifi | grep '^no:'  | sed 's/^no:/   /' | sort -u)

LIST=$(printf "%s\n%s" "$CONNECTED" "$AVAILABLE" | grep -v '^$' | awk '!seen[$0]++')

CHOICE=$(echo "$LIST" | wofi $WOFI_ARGS)
[[ -z "$CHOICE" ]] && exit 0

SSID=$(echo "$CHOICE" | sed 's/^[✔ ]*//')

# If already connected to this SSID, disconnect; otherwise connect
if nmcli -t -f active,ssid device wifi | grep -q "^yes:$SSID$"; then
  nmcli connection down "$SSID" 2>/dev/null || nmcli device disconnect wlan0
  notify-send -t 2000 "Network" "Disconnected from $SSID"
else
  # Try saved connection first, then prompt for password via wofi
  if nmcli connection up "$SSID" 2>/dev/null; then
    notify-send -t 2000 "Network" "Connected to $SSID"
  else
    PASS=$(wofi --dmenu --password --prompt="Password for $SSID" --width=320 --lines=1)
    [[ -z "$PASS" ]] && exit 0
    if nmcli device wifi connect "$SSID" password "$PASS"; then
      notify-send -t 2000 "Network" "Connected to $SSID"
    else
      notify-send -t 3000 -u critical "Network" "Failed to connect to $SSID"
    fi
  fi
fi
