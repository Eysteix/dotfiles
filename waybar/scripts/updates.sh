#!/usr/bin/env bash

official_count=0
aur_count=0

if command -v checkupdates >/dev/null 2>&1; then
	official_count=$(checkupdates 2>/dev/null | wc -l)
elif command -v pacman >/dev/null 2>&1; then
	official_count=$(pacman -Qu 2>/dev/null | wc -l)
elif command -v apt >/dev/null 2>&1; then
	official_count=$(apt list --upgradable 2>/dev/null | tail -n +2 | wc -l)
fi

if command -v paru >/dev/null 2>&1; then
	aur_count=$(paru -Qua 2>/dev/null | wc -l)
elif command -v yay >/dev/null 2>&1; then
	aur_count=$(yay -Qua 2>/dev/null | wc -l)
fi

total_count=$((official_count + aur_count))
echo "	  ${total_count}"
