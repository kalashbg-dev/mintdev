#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../../lib/common.sh"

print_message "blue" "===== INSTALLING DISCORD ====="
if ! is_installed discord; then
    wget -O discord.deb "https://discordapp.com/api/download?platform=linux&format=deb"
    sudo apt install -y ./discord.deb
    rm discord.deb
    check_success "Discord installation"
else
    print_message "yellow" "Discord is already installed"
fi
