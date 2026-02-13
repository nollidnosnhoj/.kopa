#!/usr/bin/env bash

PACKAGES=(
    bun
    code
    fnm
    gcc
    git
    github-cli
    go
    lazygit
    luarocks
    make
    neovim-git
    opencode-bin
    tree-sitter-cli
    zed
)

paru -S --needed --noconfirm "${PACKAGES[@]}"

# Installing language servers
go install golang.org/x/tools/gopls@latest

bun add -g typescript typescript-language-server

git config --global user.name "Dillon Johnson"
git config --global user.email "me@nollidnosnhoj.com"
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true