#!/usr/bin/env bash

CLI_PACKAGES=(
    eza
    fd
    ffmpeg
    fish
    fzf
    imagemagick
    ripgrep
    unzip
    wl-clipboard
    yazi
    zoxide
)

paru -S --needed --noconfirm "${CLI_PACKAGES[@]}"

if [ "$SHELL" != "/bin/fish" ]; then
    echo "fish is not the current shell. Change it using 'chsh -s /bin/fish'"
fi

GUI_PACKAGES=(
    bitwarden
    evince
    helium-browser-bin
    imv
    mpv
    vesktop
    wezterm-git
    zen-browser-bin
)

paru -S --needed --noconfirm "${GUI_PACKAGES[@]}"