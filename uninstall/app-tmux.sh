#!/bin/bash

# Script de desinstalación para Tmux en Linux Mint

# Variables y funciones
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."
source "$SCRIPT_DIR/lib/common.sh"

print_message "blue" "===== DESINSTALANDO TMUX ====="

# Confirmar desinstalación
read -p "¿Estás seguro de que deseas desinstalar Tmux? (s/n): " confirm
if [[ "$confirm" != [Ss]* ]]; then
    print_message "yellow" "Desinstalación de Tmux cancelada."
    exit 0
fi

# Eliminar plugins de Tmux
if [ -d "$HOME/.tmux/plugins" ]; then
    read -p "¿Eliminar plugins de Tmux? (s/n): " confirm_plugins
    if [[ "$confirm_plugins" == [Ss]* ]]; then
        rm -rf "$HOME/.tmux/plugins"
        print_message "yellow" "Plugins de Tmux eliminados"
    fi
fi

# Eliminar configuración de Tmux
if [ -f "$HOME/.tmux.conf" ]; then
    read -p "¿Eliminar archivo de configuración de Tmux? (s/n): " confirm_config
    if [[ "$confirm_config" == [Ss]* ]]; then
        rm -f "$HOME/.tmux.conf"
        print_message "yellow" "Archivo de configuración de Tmux eliminado"
    fi
fi

# Desinstalar Tmux
read -p "¿Desinstalar completamente Tmux del sistema? (s/n): " confirm_uninstall
if [[ "$confirm_uninstall" == [Ss]* ]]; then
    sudo apt remove --purge -y tmux
    sudo apt autoremove -y
    print_message "green" "✓ Tmux desinstalado completamente"
else
    print_message "yellow" "Tmux permanece instalado en el sistema"
fi

print_message "green" "✓ Desinstalación de Tmux completada"
