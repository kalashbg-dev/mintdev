#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../lib/common.sh"

print_message "blue" "===== INSTALLING BTOP ====="
if ! is_installed btop; then
    sudo apt install -y btop
    check_success "Btop installation"
else
    print_message "yellow" "Btop is already installed"
fi
