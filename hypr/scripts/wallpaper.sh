#!/usr/bin/env bash
# ~/.config/hypr/scripts/wallpaper.sh
# Cycles through all images in WALLPAPER_DIR on an interval

WALLPAPER_DIR="$HOME/Pictures"
INTERVAL=300   # seconds between changes (300 = 5 minutes)

# Supported formats
EXTENSIONS=("jpg" "jpeg" "png" "webp" "gif")

get_images() {
  local pattern=""
  for ext in "${EXTENSIONS[@]}"; do
    find "$WALLPAPER_DIR" -maxdepth 2 -iname "*.${ext}" 2>/dev/null
  done | sort -u
}

preload_and_set() {
  local img="$1"

  # Preload the image into hyprpaper
  hyprctl hyprpaper preload "$img"

  # Set on all monitors
  local monitors
  monitors=$(hyprctl monitors -j | grep -oP '"name":\s*"\K[^"]+')

  while IFS= read -r monitor; do
    hyprctl hyprpaper wallpaper "$monitor,$img"
  done <<< "$monitors"

  # Unload everything except current to free RAM
  hyprctl hyprpaper unload all 2>/dev/null
  hyprctl hyprpaper preload "$img"
  hyprctl hyprpaper wallpaper ",$img"
}

main() {
  # Wait for hyprpaper to be ready
  sleep 2

  local images=()
  while IFS= read -r line; do
    images+=("$line")
  done < <(get_images)

  if [[ ${#images[@]} -eq 0 ]]; then
    echo "No images found in $WALLPAPER_DIR"
    exit 1
  fi

  # Shuffle order
  mapfile -t images < <(printf '%s\n' "${images[@]}" | shuf)

  local index=0
  while true; do
    local current="${images[$index]}"
    echo "Setting wallpaper: $current"
    preload_and_set "$current"

    index=$(( (index + 1) % ${#images[@]} ))

    # Re-shuffle when we've gone through all images
    if [[ $index -eq 0 ]]; then
      mapfile -t images < <(printf '%s\n' "${images[@]}" | shuf)
    fi

    sleep "$INTERVAL"
  done
}

main
