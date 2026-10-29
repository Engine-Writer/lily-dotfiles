#!/usr/bin/env bash
set -uo pipefail

WALLPAPER_DIR="${HOME}/.config/Wallpapers"
INTERVAL=3600

mkdir -p -- "$HOME/.cache"
exec 9>"$HOME/.cache/dotfiles-wallpaper-cycle.lock"
flock -n 9 || exit 0

for i in $(seq 1 30); do
    hyprctl hyprpaper listloaded &>/dev/null && break
    sleep 1
done

if [[ ! -d "$WALLPAPER_DIR" ]]; then
    printf 'wallpaper-cycle: wallpaper directory not found: %s\n' "$WALLPAPER_DIR" >&2
    exit 1
fi

INDEX=0
PREV=""

while true; do
    mapfile -t WALLPAPERS < <(
        find "$WALLPAPER_DIR" -maxdepth 1 -type f \
            \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
        | sort
    )

    if [[ ${#WALLPAPERS[@]} -eq 0 ]]; then
        printf 'wallpaper-cycle: no images found in %s\n' "$WALLPAPER_DIR" >&2
        sleep "$INTERVAL"
        continue
    fi

    INDEX=$((INDEX % ${#WALLPAPERS[@]}))
    CURRENT="${WALLPAPERS[$INDEX]}"

    hyprctl hyprpaper preload "$CURRENT" &>/dev/null

    monitor_json=$(hyprctl monitors -j 2>/dev/null) || monitor_json='[]'
    monitor_names=$(jq -r '.[].name' <<< "$monitor_json" 2>/dev/null) || monitor_names=""
    while IFS= read -r monitor; do
        [[ -n "$monitor" ]] || continue
        hyprctl hyprpaper wallpaper "$monitor,$CURRENT" &>/dev/null
    done <<< "$monitor_names"

    if [[ -n "$PREV" ]]; then
        hyprctl hyprpaper unload "$PREV" &>/dev/null
    fi

    PREV="$CURRENT"
    INDEX=$(( (INDEX + 1) % ${#WALLPAPERS[@]} ))

    sleep "$INTERVAL"
done
