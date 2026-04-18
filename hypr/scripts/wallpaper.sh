#!/usr/bin/env bash
# ~/.config/hypr/scripts/wallpaper.sh
# Cycles through all images in WALLPAPER_DIR on an interval using awww.
# SIGUSR1 skips to the next wallpaper immediately.

WALLPAPER_DIR="$HOME/Pictures"
INTERVAL=300   # seconds between changes (300 = 5 minutes)
TRANSITION_TYPE="any"
TRANSITION_DURATION=1

PIDFILE="${XDG_RUNTIME_DIR:-/tmp}/wallpaper.pid"

EXTENSIONS=("jpg" "jpeg" "png" "webp" "gif" "bmp")

get_images() {
  for ext in "${EXTENSIONS[@]}"; do
    find "$WALLPAPER_DIR" -maxdepth 2 -iname "*.${ext}" 2>/dev/null
  done | sort -u
}

wait_for_daemon() {
  for _ in {1..40}; do
    awww query >/dev/null 2>&1 && return 0
    sleep 0.25
  done
  return 1
}

sleep_pid=""
trap 'kill "$sleep_pid" 2>/dev/null' USR1

interruptible_sleep() {
  sleep "$1" &
  sleep_pid=$!
  wait "$sleep_pid" 2>/dev/null
  sleep_pid=""
}

main() {
  # Prevent duplicate instances
  if [[ -f "$PIDFILE" ]]; then
    local existing
    existing=$(cat "$PIDFILE" 2>/dev/null)
    if [[ -n "$existing" ]] && kill -0 "$existing" 2>/dev/null; then
      echo "wallpaper.sh already running (pid $existing)" >&2
      exit 0
    fi
  fi
  echo $$ > "$PIDFILE"
  trap 'rm -f "$PIDFILE"' EXIT

  if ! wait_for_daemon; then
    # Try to start awww-daemon ourselves if it isn't running yet
    awww-daemon >/dev/null 2>&1 &
    disown
    wait_for_daemon || { echo "awww-daemon not reachable" >&2; exit 1; }
  fi

  local images=()
  while IFS= read -r line; do
    images+=("$line")
  done < <(get_images)

  if [[ ${#images[@]} -eq 0 ]]; then
    echo "No images found in $WALLPAPER_DIR" >&2
    exit 1
  fi

  mapfile -t images < <(printf '%s\n' "${images[@]}" | shuf)

  local index=0
  while true; do
    local current="${images[$index]}"
    echo "Setting wallpaper: $current"

    if awww img "$current" \
         --transition-type "$TRANSITION_TYPE" \
         --transition-duration "$TRANSITION_DURATION" 2>&1; then
      # Regenerate matugen palette — its post-hooks reload waybar/swaync/hyprland/kitty
      matugen --prefer saturation image "$current" >/dev/null 2>&1 || \
        echo "matugen failed for $current" >&2
      interruptible_sleep "$INTERVAL"
    else
      echo "awww img failed for $current" >&2
      interruptible_sleep 2
    fi

    index=$(( (index + 1) % ${#images[@]} ))
    if [[ $index -eq 0 ]]; then
      mapfile -t images < <(printf '%s\n' "${images[@]}" | shuf)
    fi
  done
}

main
