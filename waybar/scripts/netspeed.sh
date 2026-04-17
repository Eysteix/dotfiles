#!/usr/bin/env bash
# ~/.config/waybar/scripts/netspeed.sh
# Shows live upload and download speed.
# Reads from /proc/net/dev — no extra deps needed.

INTERVAL=2

# Detect the active interface (first non-lo up interface)
IFACE=$(ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if ($i=="dev") print $(i+1)}' | head -1)

if [[ -z "$IFACE" ]]; then
  echo "󰤭 offline"
  exit 0
fi

get_bytes() {
  awk -v iface="$IFACE:" '$1==iface {print $2, $10}' /proc/net/dev
}

format_speed() {
  local bytes=$1
  if   (( bytes >= 1048576 )); then printf "%.1f MB/s" "$(echo "$bytes 1048576" | awk '{printf "%.1f", $1/$2}')";
  elif (( bytes >= 1024 ))   ; then printf "%.0f KB/s" "$(echo "$bytes 1024"    | awk '{printf "%.0f", $1/$2}')";
  else printf "%d B/s" "$bytes"
  fi
}

read -r rx1 tx1 <<< "$(get_bytes)"
sleep "$INTERVAL"
read -r rx2 tx2 <<< "$(get_bytes)"

rx_speed=$(( (rx2 - rx1) / INTERVAL ))
tx_speed=$(( (tx2 - tx1) / INTERVAL ))

[[ $rx_speed -lt 0 ]] && rx_speed=0
[[ $tx_speed -lt 0 ]] && tx_speed=0

DOWN=$(format_speed "$rx_speed")
UP=$(format_speed "$tx_speed")

echo "󰇚 $DOWN  󰕒 $UP"
