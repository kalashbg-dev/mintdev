#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../../lib/common.sh"

print_message "blue" "===== INSTALLING CURSOR ====="
if ! is_installed cursor; then
    wget -O cursor.AppImage "https://downloader.cursor.sh/linux/appImage/x64"
    chmod +x cursor.AppImage
    sudo mv cursor.AppImage /usr/local/bin/cursor

    # Create desktop entry
    cat << 'EOF' | sudo tee /usr/share/applications/cursor.desktop
[Desktop Entry]
Name=Cursor
Exec=/usr/local/bin/cursor
Terminal=false
Type=Application
Icon=cursor
StartupWMClass=Cursor
Categories=Development;
EOF
    check_success "Cursor installation"
else
    print_message "yellow" "Cursor is already installed"
fi
