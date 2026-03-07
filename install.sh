#!/usr/bin/env bash

set -e

# Make all installation scripts executable
chmod +x ./install/*.sh

# Execute each installation scripts
for f in ./install/*.sh; do
    source "$f"
done

# get git submodules, including the nvim configuration
git submodule update --init --recursive
