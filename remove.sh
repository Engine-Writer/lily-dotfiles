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

bash "$repo_root/scripts/removers/remove-hyprpaper.sh"
bash "$repo_root/scripts/removers/remove-hypr.sh"
bash "$repo_root/scripts/removers/remove-kitty.sh"
bash "$repo_root/scripts/removers/remove-waybar.sh"
bash "$repo_root/scripts/removers/remove-helix.sh"
bash "$repo_root/scripts/removers/remove-zshrc.sh"
bash "$repo_root/scripts/removers/remove-starship.sh"
