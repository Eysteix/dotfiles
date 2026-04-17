#!/usr/bin/env bash
# osd.sh — Dunst-based OSD for volume and brightness
# Usage: osd.sh volume|brightness|mute|mic-mute

TAG="waybar-osd"

case "$1" in
  volume)
    RAW=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
    if echo "$RAW" | grep -q MUTED; then
      ICON="🔇"
      LABEL="Muted"
      VAL=0
    else
      VAL=$(echo "$RAW" | awk '{printf "%.0f", $2 * 100}')
      if   (( VAL >= 67 )); then ICON="🔊"
      elif (( VAL >= 34 )); then ICON="🔉"
      else                       ICON="🔈"; fi
      LABEL="Volume  $VAL%"
    fi
    ;;
  mute)
    RAW=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
    if echo "$RAW" | grep -q MUTED; then
      ICON="🔇"; LABEL="Muted"; VAL=0
    else
      VAL=$(echo "$RAW" | awk '{printf "%.0f", $2 * 100}')
      ICON="🔊"; LABEL="Unmuted  $VAL%"
    fi
    ;;
  mic-mute)
    RAW=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@)
    if echo "$RAW" | grep -q MUTED; then
      ICON="🎙️"; LABEL="Mic Muted"; VAL=0
    else
      VAL=$(echo "$RAW" | awk '{printf "%.0f", $2 * 100}')
      ICON="🎙️"; LABEL="Mic On  $VAL%"
    fi
    ;;
  brightness)
    VAL=$(brightnessctl -m | awk -F, '{gsub(/%/,""); print $4}')
    if   (( VAL >= 67 )); then ICON="🔆"
    elif (( VAL >= 34 )); then ICON="🔅"
    else                       ICON="🌑"; fi
    LABEL="Brightness  $VAL%"
    ;;
  *)
    exit 1
    ;;
esac

dunstify \
  --appname="osd" \
  --urgency=low \
  --timeout=1500 \
  --hints="int:value:$VAL" \
  --hints="string:x-dunst-stack-tag:$TAG" \
  "$ICON  $LABEL"
