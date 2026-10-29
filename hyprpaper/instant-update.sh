#!/usr/bin/env bash
set -Eeuo pipefail

WALLPAPER_DIR="${HOME}/.config/Wallpapers"

if [[ ! -d "$WALLPAPER_DIR" ]]; then
    printf 'instant-update: wallpaper directory not found: %s\n' "$WALLPAPER_DIR" >&2
    exit 1
fi

mapfile -t WALLPAPERS < <(
    find "$WALLPAPER_DIR" -maxdepth 1 -type f \
        \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
    | sort
)

if [[ ${#WALLPAPERS[@]} -eq 0 ]]; then
    echo "instant-update: no images found in $WALLPAPER_DIR" >&2
    exit 1
fi

WALLPAPER="${WALLPAPERS[0]}"

monitor_json=$(hyprctl monitors -j)
monitor_names=$(jq -r '.[].name' <<< "$monitor_json")
if [[ -z "$monitor_names" ]]; then
    printf 'instant-update: no active monitors found\n' >&2
    exit 1
fi

while IFS= read -r monitor; do
    [[ -n "$monitor" ]] || continue
    hyprctl hyprpaper wallpaper "$monitor,$WALLPAPER"
done <<< "$monitor_names"
