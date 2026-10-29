#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/../lib.sh"
REPO_ROOT=$(cd -- "$SCRIPT_DIR/../.." && pwd)

install_config "$REPO_ROOT/waybar" "$HOME/.config/waybar"
