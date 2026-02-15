PACKAGES=(
    adw-gtk-theme
    cava
    cliphist
    ddcutil
    fuzzel
    nautilus
    niri
    noctalia-shell
    nwg-look
    quickshell-git
    wlsunset
    xdg-desktop-portal
    xdg-desktop-portal-gnome
    xdg-desktop-portal-gtk
    xwayland-satellite
)

paru -S --needed --noconfirm "${PACKAGES[@]}"

gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'