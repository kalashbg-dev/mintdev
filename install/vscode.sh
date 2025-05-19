#!/bin/bash

# Script de instalación para Visual Studio Code en Linux Mint

# Obtener directorio del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/security.sh"
source "$SCRIPT_DIR/../lib/idempotence.sh"

# Antes de instalar VS Code, verificar si ya está instalado
if is_component_installed "vscode"; then
    print_message "yellow" "VS Code ya está instalado"
    log_message "INFO" "VS Code ya está instalado, omitiendo instalación"
    exit 0
fi

print_message "blue" "===== INSTALANDO VISUAL STUDIO CODE ====="
if ! is_installed code; then
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f packages.microsoft.gpg

    sudo apt update && sudo apt install -y code
    check_success "Instalación de Visual Studio Code"
    
    # Instalar extensiones populares para desarrollo
    print_message "yellow" "Instalando extensiones de VS Code..."
    code --install-extension ms-python.python
    code --install-extension dbaeumer.vscode-eslint
    code --install-extension esbenp.prettier-vscode
    code --install-extension formulahendry.auto-rename-tag
    code --install-extension ritwickdey.LiveServer
    code --install-extension ms-azuretools.vscode-docker
    code --install-extension ms-vscode.cpptools
    code --install-extension golang.go
    code --install-extension PKief.material-icon-theme
    code --install-extension dracula-theme.theme-dracula
    
    # Instalar extensiones según el tema seleccionado
    case $THEME_NAME in
        "tokyo-night")
            code --install-extension enkia.tokyo-night
            ;;
        "catppuccin")
            code --install-extension Catppuccin.catppuccin-vsc
            ;;
        "nord")
            code --install-extension arcticicestudio.nord-visual-studio-code
            ;;
        "gruvbox")
            code --install-extension jdinhlife.gruvbox
            ;;
        "dracula")
            code --install-extension dracula-theme.theme-dracula
            ;;
    esac
    
    check_success "Instalación de extensiones de VS Code"
    mark_component_installed "vscode"
else
    print_message "yellow" "Visual Studio Code ya está instalado"
fi
