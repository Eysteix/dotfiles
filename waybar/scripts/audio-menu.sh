#!/usr/bin/env bash
# audio-menu.sh — wofi audio sink / source picker using wpctl
# Left-click: pick output sink
# Right-click (pass "source" arg): pick input source

WOFI_ARGS="--dmenu --insensitive --width=380 --lines=8"

MODE="${1:-sink}"

if [[ "$MODE" == "source" ]]; then
  PROMPT="Input Source"
  # List input sources
  ITEMS=$(wpctl status | awk '/Sources:/,/^$/' | grep '│' | sed 's/.*│//' | grep -v '^$')
else
  PROMPT="Audio Output"
  # List sinks
  ITEMS=$(wpctl status | awk '/Sinks:/,/^$/' | grep '│' | sed 's/.*│//' | grep -v '^$')
fi

CHOICE=$(echo "$ITEMS" | wofi $WOFI_ARGS --prompt="$PROMPT")
[[ -z "$CHOICE" ]] && exit 0

# Extract the numeric ID at the start of the line (e.g. "* 47. Speakers")
ID=$(echo "$CHOICE" | grep -oP '^\s*\*?\s*\K\d+')
[[ -z "$ID" ]] && exit 0

if [[ "$MODE" == "source" ]]; then
  wpctl set-default "$ID"
  NAME=$(echo "$CHOICE" | sed 's/^[^.]*\. *//' | xargs)
  notify-send -t 2000 "Audio Input" "Switched to $NAME"
else
  wpctl set-default "$ID"
  NAME=$(echo "$CHOICE" | sed 's/^[^.]*\. *//' | xargs)
  notify-send -t 2000 "Audio Output" "Switched to $NAME"
fi
