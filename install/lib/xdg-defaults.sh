find_desktop_file() {
    local desktop_file
    for desktop_file in "$@"; do
        if [ -f "/usr/share/applications/$desktop_file" ] || [ -f "$HOME/.local/share/applications/$desktop_file" ]; then
            printf '%s\n' "$desktop_file"
            return 0
        fi
    done

    return 1
}

set_mime_defaults() {
    local desktop_file="$1"
    shift

    if [ -z "$desktop_file" ]; then
        return
    fi

    for mime_type in "$@"; do
        xdg-mime default "$desktop_file" "$mime_type"
    done
}

configure_default_apps() {
    local qimgv_desktop
    local mpv_desktop
    local evince_desktop
    local zen_desktop

    if ! command -v xdg-mime >/dev/null 2>&1; then
        return
    fi

    qimgv_desktop="$(find_desktop_file qimgv.desktop)"
    mpv_desktop="$(find_desktop_file io.mpv.Mpv.desktop mpv.desktop)"
    evince_desktop="$(find_desktop_file org.gnome.Evince.desktop evince.desktop)"
    zen_desktop="$(find_desktop_file zen-browser.desktop zen.desktop zen-browser-bin.desktop)"

    set_mime_defaults "$qimgv_desktop" \
        image/png \
        image/jpeg \
        image/gif \
        image/webp \
        image/bmp \
        image/tiff \
        image/svg+xml \
        image/x-xpixmap \
        image/avif \
        image/heif \
        image/heic

    set_mime_defaults "$mpv_desktop" \
        video/mp4 \
        video/webm \
        video/x-matroska \
        video/quicktime \
        video/x-msvideo \
        video/ogg \
        video/mpeg \
        audio/mpeg \
        audio/flac \
        audio/wav \
        audio/x-wav \
        audio/ogg \
        audio/opus \
        audio/aac \
        audio/mp4 \
        audio/x-m4a

    set_mime_defaults "$evince_desktop" application/pdf

    set_mime_defaults "$zen_desktop" \
        text/html \
        application/xhtml+xml \
        x-scheme-handler/http \
        x-scheme-handler/https

    if [ -n "$zen_desktop" ] && command -v xdg-settings >/dev/null 2>&1; then
        if [ -n "${BROWSER:-}" ]; then
            printf '%s\n' "BROWSER is set to '$BROWSER'; skipping xdg-settings default browser change."
        else
            xdg-settings set default-web-browser "$zen_desktop"
        fi
    fi
}
