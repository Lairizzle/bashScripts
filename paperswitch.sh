#!/usr/bin/env bash

WALL_DIR="$HOME/.config/wallpapers"

# Select wallpaper with rofi
selected=$(find "$WALL_DIR" -type f \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
    | sort \
    | rofi -dmenu -i -p "Wallpaper")

# Exit if nothing selected
[ -z "$selected" ] && exit 0

# Kill existing swaybg instance
pkill swaybg

# Start new wallpaper
swaybg -i "$selected" -m fill &
