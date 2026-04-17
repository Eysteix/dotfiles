#!/usr/bin/env bash
# lock.sh — pick a random wallpaper from ~/Pictures then lock with hyprlock

PICS_DIR="$HOME/Pictures"

# Gather all images (top-level + one level deep)
mapfile -t IMAGES < <(find "$PICS_DIR" -maxdepth 2 \
  \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) 2>/dev/null)

if [[ ${#IMAGES[@]} -gt 0 ]]; then
  WALL="${IMAGES[RANDOM % ${#IMAGES[@]}]}"
  ln -sf "$WALL" /tmp/hyprlock-wallpaper
else
  # Fallback: screenshot the current desktop
  rm -f /tmp/hyprlock-wallpaper
fi

hyprlock
