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

chsh -s $(which fish)

GUI_PACKAGES=(
    bitwarden
    evince
    foot
    helium-browser-bin
    mpv
    podman-desktop
    qimgv-git
    vesktop
    zen-browser-bin
)

paru -S --needed --noconfirm "${GUI_PACKAGES[@]}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/xdg-defaults.sh"
configure_default_apps
