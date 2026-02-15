CLI_PACKAGES=(
    eza
    fd
    ffmpeg
    fish
    fzf
    imagemagick
    ripgrep
    starship
    unzip
    wl-clipboard
    yazi
    zellij
    zoxide
)

paru -S --needed --noconfirm "${CLI_PACKAGES[@]}"

if [ "$SHELL" != "/bin/fish" ]; then
    echo "fish is not the current shell. Change it using 'chsh -s /bin/fish'"
fi

GUI_PACKAGES=(
    bitwarden
    evince
    foot
    helium-browser-bin
    imv
    mpv
    podman-desktop
    vesktop
    zen-browser-bin
)

paru -S --needed --noconfirm "${GUI_PACKAGES[@]}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/xdg-defaults.sh"
configure_default_apps
