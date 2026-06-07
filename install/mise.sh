#!/bin/bash

# Mise (formerly rtx) installation script for dev tools management
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../lib/common.sh"

print_message "blue" "===== INSTALLING MISE ====="

if ! is_installed mise; then
    sudo apt update -y && sudo apt install -y gpg sudo wget curl
    sudo install -dm 755 /etc/apt/keyrings
    wget -qO - https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/mise-archive-keyring.gpg 1> /dev/null
    echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=amd64] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list
    sudo apt update
    sudo apt install -y mise
    check_success "Mise installation"

    # Activate mise in Zsh
    if ! grep -q 'mise activate zsh' ~/.zshrc; then
        echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
    fi
    # Activate mise in Bash
    if [ -f ~/.bashrc ] && ! grep -q 'mise activate bash' ~/.bashrc; then
        echo 'eval "$(mise activate bash)"' >> ~/.bashrc
    fi

    # Install default global tools with mise (Node.js and Python)
    print_message "blue" "Installing default global tools via mise..."
    # We use eval since mise needs to be active in the shell
    eval "$(mise activate bash)"
    mise use --global node@lts
    mise use --global python@latest

    check_success "Mise tools setup"
else
    print_message "yellow" "Mise is already installed"
fi
