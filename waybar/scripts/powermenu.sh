#!/usr/bin/env bash
# powermenu.sh — Wofi power menu
# Keybind: Super + X

LOCK="󰌾  Lock"
SUSPEND="󰤄  Suspend"
LOGOUT="󰍃  Logout"
REBOOT="󰑓  Reboot"
SHUTDOWN="󰐥  Shutdown"

CHOICE=$(printf "%s\n%s\n%s\n%s\n%s" \
  "$LOCK" "$SUSPEND" "$LOGOUT" "$REBOOT" "$SHUTDOWN" \
  | wofi \
      --dmenu \
      --prompt="Power" \
      --width=260 \
      --height=270 \
      --location=center \
      --no-actions \
      --insensitive \
      --cache-file=/dev/null \
      --style="$HOME/.config/wofi/style.css")

[[ -z "$CHOICE" ]] && exit 0

case "$CHOICE" in
  "$LOCK")     ~/.config/waybar/scripts/lock.sh ;;
  "$SUSPEND")  systemctl suspend ;;
  "$LOGOUT")   hyprctl dispatch exit ;;
  "$REBOOT")   systemctl reboot ;;
  "$SHUTDOWN") systemctl poweroff ;;
esac
