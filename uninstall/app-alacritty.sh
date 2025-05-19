#!/bin/bash

# Script de desinstalación para Alacritty en Linux Mint

# Variables y funciones
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."
source "$SCRIPT_DIR/lib/common.sh"

print_message "blue" "===== DESINSTALANDO ALACRITTY ====="

# Confirmar desinstalación
read -p "¿Estás seguro de que deseas desinstalar Alacritty? (s/n): " confirm
if [[ "$confirm" != [Ss]* ]]; then
    print_message "yellow" "Desinstalación de Alacritty cancelada."
    exit 0
fi

# Eliminar binario instalado manualmente
if [ -f "/usr/local/bin/alacritty" ]; then
    sudo rm -f /usr/local/bin/alacritty
    print_message "yellow" "Eliminado binario de Alacritty"
fi

# Eliminar archivos de escritorio
if [ -f "/usr/share/applications/Alacritty.desktop" ]; then
    sudo rm -f /usr/share/applications/Alacritty.desktop
    sudo update-desktop-database
    print_message "yellow" "Eliminado archivo de escritorio de Alacritty"
fi

# Eliminar ícono
if [ -f "/usr/share/pixmaps/Alacritty.svg" ]; then
    sudo rm -f /usr/share/pixmaps/Alacritty.svg
    print_message "yellow" "Eliminado ícono de Alacritty"
fi

# Eliminar páginas de manual
if [ -f "/usr/local/share/man/man1/alacritty.1.gz" ]; then
    sudo rm -f /usr/local/share/man/man1/alacritty.1.gz
    print_message "yellow" "Eliminada página de manual de Alacritty"
fi

if [ -f "/usr/local/share/man/man1/alacritty-msg.1.gz" ]; then
    sudo rm -f /usr/local/share/man/man1/alacritty-msg.1.gz
    print_message "yellow" "Eliminada página de manual de alacritty-msg"
fi

# Eliminar configuración
if [ -d "$HOME/.config/alacritty" ]; then
    read -p "¿Deseas eliminar los archivos de configuración de Alacritty? (s/n): " confirm_config
    if [[ "$confirm_config" == [Ss]* ]]; then
        rm -rf "$HOME/.config/alacritty"
        print_message "yellow" "Eliminada configuración de Alacritty"
    else
        print_message "yellow" "Configuración de Alacritty conservada en $HOME/.config/alacritty"
    fi
fi

# Eliminar completación de zsh
if [ -f "${ZDOTDIR:-$HOME}/.zsh_functions/_alacritty" ]; then
    rm -f "${ZDOTDIR:-$HOME}/.zsh_functions/_alacritty"
    print_message "yellow" "Eliminada completación de Zsh para Alacritty"
fi

print_message "green" "✓ Alacritty ha sido desinstalado correctamente"
