#!/bin/sh

set -e

PLASMOID_NAME="com.github.galib.cutoff"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

usage() {
    echo "Usage: $0 <install|uninstall|update> <local|global>"
    echo ""
    echo "Examples:"
    echo "  $0 install local     # Install to ~/.local/share/plasma/plasmoids (no sudo)"
    echo "  $0 install global    # Install to /usr/share/plasma/plasmoids (requires sudo)"
    echo "  $0 uninstall local   # Remove from local directories"
    echo "  $0 uninstall global  # Remove from system directories"
    exit 1
}

# Require exactly two arguments
if [ "$#" -ne 2 ]; then
    usage
fi

ACTION="$1"
TARGET="$2"

case "$TARGET" in
    local)
        GLOBAL_FLAG=""
        ;;
    global)
        GLOBAL_FLAG="--global"
        ;;
    *)
        echo "Error: Target must be 'local' or 'global'."
        usage
        ;;
esac

_sudo() {
    if command -v sudo >/dev/null; then
        sudo "$@"
    elif command -v doas >/dev/null; then
        doas "$@"
    else
        echo "Failed to execute '$*'. Please run the script with root permissions." >&2
        exit 1
    fi
}

install_widget() {
    echo "=> Installing $PLASMOID_NAME ($TARGET) ..."
    
    if [ "$TARGET" = "local" ]; then
        kpackagetool6 -t Plasma/Applet -i "$SCRIPT_DIR"
    else
        _sudo kpackagetool6 -t Plasma/Applet $GLOBAL_FLAG -i "$SCRIPT_DIR"
    fi
}

update_widget() {
    echo "=> Updating $PLASMOID_NAME ($TARGET) ..."
    
    if [ "$TARGET" = "local" ]; then
        kpackagetool6 -t Plasma/Applet -u "$SCRIPT_DIR"
    else
        _sudo kpackagetool6 -t Plasma/Applet $GLOBAL_FLAG -u "$SCRIPT_DIR"
    fi
}

uninstall_widget() {
    echo "=> Removing $PLASMOID_NAME ($TARGET) ..."

    if [ "$TARGET" = "local" ]; then
        kpackagetool6 -t Plasma/Applet -r "$PLASMOID_NAME" || echo "  Not installed locally."
    else
        _sudo kpackagetool6 -t Plasma/Applet $GLOBAL_FLAG -r "$PLASMOID_NAME" || echo "  Not installed globally."
    fi
}

case "$ACTION" in
    install)   
        install_widget 
        ;;
    uninstall) 
        uninstall_widget 
        ;;
    update)    
        update_widget
        echo "You may need to restart Plasma (log out/in or run: systemctl restart --user plasma-plasmashell.service) to see changes."
        ;;
    *)
        echo "Error: Action must be 'install', 'uninstall', or 'update'."
        usage
        ;;
esac
