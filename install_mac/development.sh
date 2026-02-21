#!/usr/bin/env bash

PACKAGES=(
    gcc
    git
    gh
    lazygit
    lua-language-server
    luarocks
    markdown-oxide
    mise
    neovim
    anomalyco/tap/opencode
    tree-sitter-cli
    usage # required by mise
)

brew install "${PACKAGES[@]}"

mise install

# Installing language servers
mise exec -- go install golang.org/x/tools/gopls@latest
mise exec -- bun add -g typescript typescript-language-server
