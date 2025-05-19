#!/bin/bash

# Script de desinstalación para Ranger en Linux Mint

# Variables y funciones
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."
source "$SCRIPT_DIR/lib/common.sh"

print_message "blue" "===== DESINSTALANDO RANGER ====="

# Confirmar desinstalación
read -p "¿Estás seguro de que deseas desinstalar Ranger? (s/n): " confirm
if [[ "$confirm" != [Ss]* ]]; then
    print_message "yellow" "Desinstalación de Ranger cancelada."
    exit 0
fi

# Eliminar configuración de Ranger
if [ -d "$HOME/.config/ranger" ]; then
    read -p "¿Eliminar archivos de configuración de Ranger? (s/n): " confirm_config
    if [[ "$confirm_config" == [Ss]* ]]; then
        rm -rf "$HOME/.config/ranger"
        print_message "yellow" "Archivos de configuración de Ranger eliminados"
    fi
fi

# Eliminar alias en .zshrc y .bashrc
if [ -f "$HOME/.zshrc" ] && grep -q "alias r='ranger'" "$HOME/.zshrc"; then
    read -p "¿Eliminar alias de Ranger en .zshrc? (s/n): " confirm_zsh
    if [[ "$confirm_zsh" == [Ss]* ]]; then
        sed -i '/alias r=.ranger./d' "$HOME/.zshrc"
        print_message "yellow" "Alias de Ranger eliminados de .zshrc"
    fi
fi

if [ -f "$HOME/.bashrc" ] && grep -q "alias r='ranger'" "$HOME/.bashrc"; then
    read -p "¿Eliminar alias de Ranger en .bashrc? (s/n): " confirm_bash
    if [[ "$confirm_bash" == [Ss]* ]]; then
        sed -i '/alias r=.ranger./d' "$HOME/.bashrc"
        print_message "yellow" "Alias de Ranger eliminados de .bashrc"
    fi
fi

# Desinstalar Ranger y dependencias
if is_installed ranger; then
    read -p "¿Desinstalar completamente Ranger del sistema? (s/n): " confirm_uninstall
    if [[ "$confirm_uninstall" == [Ss]* ]]; then
        sudo apt remove --purge -y ranger
        read -p "¿Desinstalar también las dependencias de Ranger (highlight, caca-utils, etc.)? (s/n): " confirm_deps
        if [[ "$confirm_deps" == [Ss]* ]]; then
            sudo apt remove --purge -y highlight caca-utils w3m poppler-utils mediainfo
            print_message "yellow" "Dependencias de Ranger desinstaladas"
        fi
        sudo apt autoremove -y
        print_message "green" "✓ Ranger desinstalado completamente"
    else
        print_message "yellow" "Ranger permanece instalado en el sistema"
    fi
else
    print_message "yellow" "Ranger no está instalado en el sistema"
fi

print_message "green" "✓ Desinstalación de Ranger completada"
