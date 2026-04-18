#!/usr/bin/env bash
# Signal wallpaper.sh to skip to the next image.
pid_file="${XDG_RUNTIME_DIR:-/tmp}/wallpaper.pid"
[[ -f "$pid_file" ]] || exit 0
pid=$(cat "$pid_file" 2>/dev/null)
[[ -n "$pid" ]] && kill -USR1 "$pid" 2>/dev/null
