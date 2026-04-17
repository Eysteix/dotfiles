#!/usr/bin/env bash
# ~/.config/waybar/scripts/powerprofile.sh
# Cycles power profiles: balanced → power-saver → performance → balanced
# Run with no args to print current profile icon+name (for waybar exec).
# Run with "cycle" to advance to the next profile.

declare -A ICON=(
  [performance]="󱐋"
  [balanced]="󰗑"
  [power-saver]="󰌪"
)
declare -A LABEL=(
  [performance]="Performance"
  [balanced]="Balanced"
  [power-saver]="Power Saver"
)
ORDER=(balanced power-saver performance)

current=$(powerprofilesctl get 2>/dev/null)

if [[ "$1" == "cycle" ]]; then
  for i in "${!ORDER[@]}"; do
    if [[ "${ORDER[$i]}" == "$current" ]]; then
      next="${ORDER[$(( (i + 1) % ${#ORDER[@]} ))]}"
      powerprofilesctl set "$next"
      notify-send -t 2000 "Power Profile" "${ICON[$next]} ${LABEL[$next]}" 2>/dev/null
      exit 0
    fi
  done
  # fallback
  powerprofilesctl set balanced
else
  icon="${ICON[$current]:-󰗑}"
  label="${LABEL[$current]:-$current}"
  echo "$icon  $label"
fi
