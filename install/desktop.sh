PACKAGES=(
    adw-gtk-theme
    brightnessctl
    capitaine-cursors
    cava
    cliphist
    ddcutil
    fuzzel
    kvantum
    nautilus
    niri
    noctalia-shell
    nwg-look
    qt5ct
    quickshell-git
    power-profiles-daemon
    wl-clipboard
    wlsunset
    xdg-desktop-portal
    xdg-desktop-portal-gnome
    xdg-desktop-portal-gtk
    xorg-xwayland
    xwayland-satellite
)

paru -S --needed --noconfirm "${PACKAGES[@]}"

gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'

mkdir -p ~/Pictures/Wallpapers
cp -r ./wallpapers/* ~/Pictures/Wallpapers/