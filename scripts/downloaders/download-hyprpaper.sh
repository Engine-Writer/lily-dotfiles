#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/../lib.sh"
REPO_ROOT=$(cd -- "$SCRIPT_DIR/../.." && pwd)
HYPRPAPER="$HOME/.config/hyprpaper"

pkill -f -- "$HYPRPAPER/wallpaper-cycle.sh" 2>/dev/null || true
install_config "$REPO_ROOT/hyprpaper" "$HYPRPAPER"
chmod +x "$HYPRPAPER/wallpaper-cycle.sh" "$HYPRPAPER/instant-update.sh"
mkdir -p -- "$HOME/.config/Wallpapers"

printf 'Starting hyprpaper scripts...\n'
nohup "$HYPRPAPER/wallpaper-cycle.sh" >/dev/null 2>&1 &
