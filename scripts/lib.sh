#!/usr/bin/env bash

next_backup_path() {
    local target="$1"
    local candidate="${target}.old"
    local number=1

    while [[ -e "$candidate" || -L "$candidate" ]]; do
        candidate="${target}-${number}.old"
        number=$((number + 1))
    done

    printf '%s\n' "$candidate"
}

latest_backup_path() {
    local target="$1"
    local candidate name number latest_number=0 latest=""

    for candidate in "${target}"-*.old; do
        [[ -e "$candidate" || -L "$candidate" ]] || continue
        name=${candidate##*/}
        number=${name#"${target##*/}"-}
        number=${number%.old}
        [[ "$number" =~ ^[0-9]+$ ]] || continue
        number=$((10#$number))
        if (( number > latest_number )); then
            latest_number=$number
            latest=$candidate
        fi
    done

    if [[ -n "$latest" ]]; then
        printf '%s\n' "$latest"
    elif [[ -e "${target}.old" || -L "${target}.old" ]]; then
        printf '%s\n' "${target}.old"
    fi
}

install_config() (
    set -Eeuo pipefail
    local source="$1" target="$2" parent stage backup=""

    if [[ ! -e "$source" && ! -L "$source" ]]; then
        printf 'Config source not found: %s\n' "$source" >&2
        return 1
    fi

    parent=$(dirname -- "$target")
    mkdir -p -- "$parent"
    stage=$(mktemp -d "$parent/.dotfiles-install.XXXXXX")
    trap 'rm -rf -- "$stage"' EXIT

    if [[ -d "$source" && ! -L "$source" ]]; then
        mkdir -- "$stage/payload"
        cp -a -- "$source"/. "$stage/payload"/
    else
        cp -a -- "$source" "$stage/payload"
    fi

    if [[ -e "$target" || -L "$target" ]]; then
        backup=$(next_backup_path "$target")
        mv -- "$target" "$backup"
    fi

    if ! mv -- "$stage/payload" "$target"; then
        if [[ -n "$backup" ]]; then
            mv -- "$backup" "$target"
        fi
        printf 'Could not install config at %s\n' "$target" >&2
        return 1
    fi

    printf 'Installed %s\n' "$target"
)

restore_config() (
    set -Eeuo pipefail
    local target="$1" parent backup stage

    backup=$(latest_backup_path "$target")
    if [[ -z "$backup" ]]; then
        printf 'No backup found for %s; leaving it unchanged.\n' "$target"
        return 0
    fi

    parent=$(dirname -- "$target")
    stage=$(mktemp -d "$parent/.dotfiles-restore.XXXXXX")
    trap 'rm -rf -- "$stage"' EXIT

    if [[ -e "$target" || -L "$target" ]]; then
        mv -- "$target" "$stage/current"
    fi

    if ! mv -- "$backup" "$target"; then
        if [[ -e "$stage/current" || -L "$stage/current" ]]; then
            mv -- "$stage/current" "$target"
        fi
        printf 'Could not restore %s from %s\n' "$target" "$backup" >&2
        return 1
    fi

    printf 'Restored %s from %s\n' "$target" "$backup"
)