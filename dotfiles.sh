#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$HOME/.kopa/dotfiles"
TARGET_DIR="$HOME"
BACKUP_SUFFIX=".bak.$(date +%Y%m%d%H%M%S)"
SELECTED_PACKAGES=()

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
        fi
    done < <(find "$package_dir" -mindepth 1 -type d -print0)

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
    local package

    require_stow

    (
        cd "$DOTFILES_DIR"
        for package in "${SELECTED_PACKAGES[@]}"; do

            if [ "$mode" = "link" ]; then
                prepare_targets_for_package "$package"
                stow --target "$TARGET_DIR" --no-folding --restow "$package"
                echo "Linked package: $package"
            else
                stow --target "$TARGET_DIR" --no-folding --delete "$package"
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
    local package source_path relative_path target_path

    for package in "${SELECTED_PACKAGES[@]}"; do
        package="$DOTFILES_DIR/$package"

        while IFS= read -r -d '' source_path; do
            relative_path="${source_path#"$package"/}"
            target_path="$TARGET_DIR/$relative_path"

            list_path "$source_path" "$target_path"
        done < <(find "$package" -mindepth 1 \( -type f -o -type l \) -print0)
    done
}

append_all_packages() {
    local package_dir package_name

    for package_dir in "$DOTFILES_DIR"/*; do
        [ -d "$package_dir" ] || continue
        package_name="$(basename "$package_dir")"
        SELECTED_PACKAGES+=("$package_name")
    done
}

print_available_packages() {
    local package_dir

    for package_dir in "$DOTFILES_DIR"/*; do
        [ -d "$package_dir" ] || continue
        printf '  %s\n' "$(basename "$package_dir")"
    done
}

package_in_list() {
    local needle="$1"
    local package

    for package in "${SELECTED_PACKAGES[@]}"; do
        if [ "$package" = "$needle" ]; then
            return 0
        fi
    done

    return 1
}

resolve_selected_packages() {
    local package_csv="${1:-}"
    local package_entry package_name
    local invalid_packages=""
    local IFS=','
    local requested_packages=()

    SELECTED_PACKAGES=()

    if [ -z "$package_csv" ]; then
        append_all_packages
    else
        read -r -a requested_packages <<< "$package_csv"

        for package_entry in "${requested_packages[@]}"; do
            package_name="${package_entry//[[:space:]]/}"

            if [ -z "$package_name" ]; then
                continue
            fi

            if [ ! -d "$DOTFILES_DIR/$package_name" ]; then
                if [ -z "$invalid_packages" ]; then
                    invalid_packages="$package_name"
                else
                    invalid_packages="$invalid_packages,$package_name"
                fi
                continue
            fi

            if ! package_in_list "$package_name"; then
                SELECTED_PACKAGES+=("$package_name")
            fi
        done
    fi

    if [ -n "${invalid_packages:-}" ]; then
        echo "Unknown package(s): $invalid_packages" >&2
        echo "Available packages:" >&2
        print_available_packages >&2
        exit 1
    fi

    if [ "${#SELECTED_PACKAGES[@]}" -eq 0 ]; then
        echo "No valid packages selected." >&2
        exit 1
    fi
}

print_usage() {
    cat <<EOF
Usage: $0 [COMMAND] [PACKAGE_CSV]

Commands:
  link      Create/update managed dotfile symlinks with stow
  unlink    Remove managed dotfile symlinks with stow
  list      Show currently linked managed dotfiles
  help      Show this help message

PACKAGE_CSV:
  Comma-separated package names from $DOTFILES_DIR
  Example: fish,git,mise,nvim,starship,yazi,zellij

When no command is provided, defaults to: list
EOF
}

if [ "$#" -gt 2 ]; then
    print_usage
    exit 1
fi

command="${1:-list}"
package_csv="${2:-}"

case "$command" in
    help|-h|--help)
        print_usage
        ;;
    link)
        resolve_selected_packages "$package_csv"
        run_stow_for_packages link
        ;;
    unlink)
        resolve_selected_packages "$package_csv"
        run_stow_for_packages unlink
        ;;
    list)
        resolve_selected_packages "$package_csv"
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
