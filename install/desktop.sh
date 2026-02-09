#!/usr/bin/env bash

PACKAGES=(
    niri
    xwayland-satellite
    xdg-desktop-portal-gnome
    xdg-desktop-portal-gtk
    noctalia-shell
    adw-gtk-theme
    nwg-look
    nautilus
    gnome-keyring
    fuzzel
)

paru -S --needed --noconfirm "${PACKAGES[@]}"

gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'