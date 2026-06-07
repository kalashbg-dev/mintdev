#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../lib/common.sh"

print_message "blue" "===== INSTALLING LAZYDOCKER ====="
if ! is_installed lazydocker; then
    # We download the script and execute it instead of piping to bash to avoid sandboxing issues
    wget -qO /tmp/install_lazydocker.sh https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh
    sh /tmp/install_lazydocker.sh
    rm /tmp/install_lazydocker.sh
    sudo install -m 755 ~/.local/bin/lazydocker /usr/local/bin/lazydocker || true
    check_success "Lazydocker installation"
else
    print_message "yellow" "Lazydocker is already installed"
fi
