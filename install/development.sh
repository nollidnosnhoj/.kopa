#!/usr/bin/env bash

PACKAGES=(
    code
    docker
    docker-compose
    gcc
    git
    github-cli
    lazydocker
    lazygit
    lua-language-server
    luarocks
    make
    markdown-oxide-git
    mise
    neovim-git
    opencode-bin
    tree-sitter-cli
    usage # required by mise
    zed
)

paru -S --needed "${PACKAGES[@]}"

mise install



# Installing language servers
mise exec -- go install golang.org/x/tools/gopls@latest
mise exec -- bun add -g typescript typescript-language-server

# enabling docker service
sudo systemctl enable --now docker.service
