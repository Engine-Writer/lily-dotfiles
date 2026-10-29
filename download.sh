#!/usr/bin/env bash
set -Eeuo pipefail

repo_root=""
if [[ -f "$0" ]]; then
	source_dir=$(dirname -- "$0")
	if [[ -d "$source_dir/scripts" ]]; then
		repo_root=$(cd -- "$source_dir" && pwd)
	fi
fi

if [[ -z "$repo_root" ]]; then
	temp_dir=$(mktemp -d)
	trap 'rm -rf -- "$temp_dir"' EXIT
	git clone --depth=1 https://github.com/transicle/dotfiles "$temp_dir/dotfiles"
	repo_root="$temp_dir/dotfiles"
fi

bash "$repo_root/scripts/dependencies.sh"
bash "$repo_root/scripts/downloaders/download-hypr.sh"
bash "$repo_root/scripts/downloaders/download-hyprpaper.sh"
bash "$repo_root/scripts/downloaders/download-kitty.sh"
bash "$repo_root/scripts/downloaders/download-waybar.sh"
bash "$repo_root/scripts/downloaders/download-helix.sh"
bash "$repo_root/scripts/downloaders/download-zshrc.sh"
bash "$repo_root/scripts/downloaders/download-starship.sh"

bash "$repo_root/scripts/config/config-files.sh"
bash "$repo_root/scripts/config/config-flatpak.sh"

if command -v hyprctl >/dev/null 2>&1; then
	hyprctl reload || printf 'Could not reload Hyprland; reload it manually.\n' >&2
fi

bash "$repo_root/scripts/fix-equicord-ipc.sh"
