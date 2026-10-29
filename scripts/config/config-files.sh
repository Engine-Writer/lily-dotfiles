#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/../lib.sh"

run() {
    printf '==> %s\n' "$*"
    "$@"
}

mkdir -p "$HOME/Videos"
mkdir -p "$HOME/Pictures"

run xdg-user-dirs-update

xdg_config="$HOME/.config/user-dirs.dirs"

if [[ -f "$xdg_config" ]]; then
    sed -i 's|^XDG_VIDEOS_DIR=.*|XDG_VIDEOS_DIR="$HOME/Videos"|' "$xdg_config"
    sed -i 's|^XDG_PICTURES_DIR=.*|XDG_PICTURES_DIR="$HOME/Pictures"|' "$xdg_config"
else
    echo "Missing $xdg_config"
    exit 1
fi

run xdg-user-dirs-update