#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$HOME/.archlinux/dotfiles"
TARGET_DIR="$HOME"
BACKUP_SUFFIX=".bak.$(date +%Y%m%d%H%M%S)"

require_stow() {
    if ! command -v stow >/dev/null 2>&1; then
        echo "stow is required but not installed." >&2
        exit 1
    fi
}

prepare_targets_for_package() {
    local package="$1"
    local package_dir="$DOTFILES_DIR/$package"

    while IFS= read -r -d '' source_path; do
        local relative_path target_path link_value target_resolved source_resolved
        relative_path="${source_path#"$package_dir"/}"
        target_path="$TARGET_DIR/$relative_path"
        source_resolved="$(readlink -f "$source_path")"

        if [ -L "$target_path" ]; then
            link_value="$(readlink "$target_path")"
            if [ "$link_value" = "$source_path" ]; then
                rm "$target_path"
                echo "Removed legacy link: $target_path"
                continue
            fi

            target_resolved="$(readlink -f "$target_path" 2>/dev/null || true)"
            if [ -n "$target_resolved" ] && [ "$target_resolved" = "$source_resolved" ]; then
                continue
            fi

            mv "$target_path" "${target_path}${BACKUP_SUFFIX}"
            echo "Backed up symlink: $target_path -> ${target_path}${BACKUP_SUFFIX}"
            continue
        fi

        if [ -e "$target_path" ]; then
            target_resolved="$(readlink -f "$target_path" 2>/dev/null || true)"
            if [ -n "$target_resolved" ] && [ "$target_resolved" = "$source_resolved" ]; then
                continue
            fi

            mv "$target_path" "${target_path}${BACKUP_SUFFIX}"
            echo "Backed up path: $target_path -> ${target_path}${BACKUP_SUFFIX}"
        fi
    done < <(find "$package_dir" -mindepth 1 \( -type f -o -type l \) -print0)
}

run_stow_for_packages() {
    local mode="$1"

    require_stow

    (
        cd "$DOTFILES_DIR"
        for package in */; do
            [ -d "$package" ] || continue
            package="${package%/}"

            if [ "$mode" = "link" ]; then
                prepare_targets_for_package "$package"
                stow --target "$TARGET_DIR" --restow "$package"
                echo "Linked package: $package"
            else
                stow --target "$TARGET_DIR" --delete "$package"
                echo "Unlinked package: $package"
            fi
        done
    )
}

LIST_COUNT=0
list_path() {
    local src="$1"
    local dest="$2"
    local current_target source_target

    if [ ! -e "$dest" ] && [ ! -L "$dest" ]; then
        return
    fi

    current_target="$(readlink -f "$dest" 2>/dev/null || true)"
    source_target="$(readlink -f "$src")"

    if [ -z "$current_target" ] || [ "$current_target" != "$source_target" ]; then
        return
    fi

    echo "Linked: $dest -> $src"
    LIST_COUNT=$((LIST_COUNT + 1))
}

run_for_all_paths() {

    for package in "$DOTFILES_DIR"/*; do
        [ -d "$package" ] || continue

        while IFS= read -r -d '' source_path; do
            relative_path="${source_path#"$package"/}"
            target_path="$TARGET_DIR/$relative_path"

            list_path "$source_path" "$target_path"
        done < <(find "$package" -mindepth 1 \( -type f -o -type l \) -print0)
    done
}

print_usage() {
    cat <<EOF
Usage: $0 [COMMAND]

Commands:
  link      Create/update managed dotfile symlinks with stow
  unlink    Remove managed dotfile symlinks with stow
  list      Show currently linked managed dotfiles
  help      Show this help message

When no command is provided, defaults to: list
EOF
}

if [ "$#" -gt 1 ]; then
    print_usage
    exit 1
fi

command="${1:-list}"

case "$command" in
    help|-h|--help)
        print_usage
        ;;
    link)
        run_stow_for_packages link
        ;;
    unlink)
        run_stow_for_packages unlink
        ;;
    list)
        run_for_all_paths
        if [ "$LIST_COUNT" -eq 0 ]; then
            echo "No managed dotfiles are currently linked."
        fi
        ;;
    *)
        print_usage
        exit 1
        ;;
esac
