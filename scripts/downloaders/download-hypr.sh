#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/../lib.sh"
REPO_ROOT=$(cd -- "$SCRIPT_DIR/../.." && pwd)

if ! command -v Hyprland >/dev/null 2>&1; then
    printf 'Hyprland is not installed; install dependencies first.\n' >&2
    exit 1
fi

version_output=$(Hyprland --version)
if [[ ! "$version_output" =~ ([0-9]+)\.([0-9]+) ]]; then
    printf 'Could not determine the installed Hyprland version: %s\n' "$version_output" >&2
    exit 1
fi

major=${BASH_REMATCH[1]}
minor=${BASH_REMATCH[2]}
if (( major == 0 && minor < 55 )); then
    printf 'Hyprland 0.55.x or newer is required (found %s.%s).\n' "$major" "$minor" >&2
    exit 1
fi

install_config "$REPO_ROOT/hypr" "$HOME/.config/hypr"
