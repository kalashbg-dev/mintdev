#!/bin/bash

# Fastfetch installation script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../lib/common.sh"

print_message "blue" "===== INSTALLING FASTFETCH ====="

if ! is_installed fastfetch; then
    sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch
    sudo apt update
    sudo apt install -y fastfetch
    check_success "Fastfetch installation"

    # Configure Fastfetch to run on shell startup
    if ! grep -q "fastfetch" ~/.zshrc; then
        echo -e "\n# Show system info\nfastfetch" >> ~/.zshrc
    fi
    if [ -f ~/.bashrc ] && ! grep -q "fastfetch" ~/.bashrc; then
        echo -e "\n# Show system info\nfastfetch" >> ~/.bashrc
    fi
else
    print_message "yellow" "Fastfetch is already installed"
fi
