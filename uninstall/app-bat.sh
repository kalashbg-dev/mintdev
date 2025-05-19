#!/bin/bash

# Script de desinstalación para Bat en Linux Mint

# Variables y funciones
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."
source "$SCRIPT_DIR/lib/common.sh"

print_message "blue" "===== DESINSTALANDO BAT ====="

# Confirmar desinstalación
read -p "¿Estás seguro de que deseas desinstalar Bat? (s/n): " confirm
if [[ "$confirm" != [Ss]* ]]; then
    print_message "yellow" "Desinstalación de Bat cancelada."
    exit 0
fi

# Eliminar configuración de Bat
if [ -d "$HOME/.config/bat" ]; then
    read -p "¿Eliminar archivos de configuración de Bat? (s/n): " confirm_config
    if [[ "$confirm_config" == [Ss]* ]]; then
        rm -rf "$HOME/.config/bat"
        print_message "yellow" "Archivos de configuración de Bat eliminados"
    fi
fi

# Eliminar alias en .zshrc y .bashrc
if [ -f "$HOME/.zshrc" ] && grep -q "alias cat='bat" "$HOME/.zshrc"; then
    read -p "¿Eliminar alias de Bat en .zshrc? (s/n): " confirm_zsh
    if [[ "$confirm_zsh" == [Ss]* ]]; then
        sed -i '/alias cat=.bat/d' "$HOME/.zshrc"
        sed -i '/alias less=.bat/d' "$HOME/.zshrc"
        print_message "yellow" "Alias de Bat eliminados de .zshrc"
    fi
fi

if [ -f "$HOME/.bashrc" ] && grep -q "alias cat='bat" "$HOME/.bashrc"; then
    read -p "¿Eliminar alias de Bat en .bashrc? (s/n): " confirm_bash
    if [[ "$confirm_bash" == [Ss]* ]]; then
        sed -i '/alias cat=.bat/d' "$HOME/.bashrc"
        sed -i '/alias less=.bat/d' "$HOME/.bashrc"
        print_message "yellow" "Alias de Bat eliminados de .bashrc"
    fi
fi

# Eliminar enlace simbólico
if [ -L "/usr/local/bin/bat" ]; then
    sudo rm -f /usr/local/bin/bat
    print_message "yellow" "Enlace simbólico de Bat eliminado"
fi

# Desinstalar Bat
if is_installed bat || is_installed batcat; then
    read -p "¿Desinstalar completamente Bat del sistema? (s/n): " confirm_uninstall
    if [[ "$confirm_uninstall" == [Ss]* ]]; then
        sudo apt remove --purge -y bat batcat
        sudo apt autoremove -y
        print_message "green" "✓ Bat desinstalado completamente"
    else
        print_message "yellow" "Bat permanece instalado en el sistema"
    fi
else
    print_message "yellow" "Bat no está instalado en el sistema"
fi

print_message "green" "✓ Desinstalación de Bat completada"
