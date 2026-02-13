#!/usr/bin/env bash

set -e

# check if the current directory is in $HOME/.archlinux
if [ "$(pwd -P)" != "$HOME/.archlinux" ]; then
    echo 'This script should be installed from .archlinux folder'
    exit 1
fi

# Make dotfiles script executable
chmod +x ./dotfiles.sh

# Update dotfiles
./dotfiles.sh link

# Make all installation scripts executable
chmod +x ./install/*.sh

# Execute each installation scripts
for f in ./install/*.sh; do
    source "$f"
done

# get git submodules, including the nvim configuration
git submodule update --init --recursive
