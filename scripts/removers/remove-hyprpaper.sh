#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/../lib.sh"
HYPRPAPER="$HOME/.config/hyprpaper"

pkill -f -- "$HYPRPAPER/wallpaper-cycle.sh" 2>/dev/null || true
restore_config "$HYPRPAPER"
