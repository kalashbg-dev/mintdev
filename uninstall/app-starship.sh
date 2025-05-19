#!/bin/bash

# Script de desinstalación para Starship Prompt en Linux Mint

# Variables y funciones
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."
source "$SCRIPT_DIR/lib/common.sh"

print_message "blue" "===== DESINSTALANDO STARSHIP PROMPT ====="

# Confirmar desinstalación
read -p "¿Estás seguro de que deseas desinstalar Starship? (s/n): " confirm
if [[ "$confirm" != [Ss]* ]]; then
    print_message "yellow" "Desinstalación de Starship cancelada."
    exit 0
fi

# Eliminar configuración de Starship
if [ -f "$HOME/.config/starship.toml" ]; then
    read -p "¿Eliminar archivo de configuración de Starship? (s/n): " confirm_config
    if [[ "$confirm_config" == [Ss]* ]]; then
        rm -f "$HOME/.config/starship.toml"
        print_message "yellow" "Archivo de configuración de Starship eliminado"
    fi
fi

# Eliminar referencias a Starship en archivos de shell
if [ -f "$HOME/.zshrc" ] && grep -q "starship init" "$HOME/.zshrc"; then
    read -p "¿Eliminar Starship de la configuración de Zsh? (s/n): " confirm_zsh
    if [[ "$confirm_zsh" == [Ss]* ]]; then
        sed -i '/starship init/d' "$HOME/.zshrc"
        print_message "yellow" "Starship eliminado de la configuración de Zsh"
    fi
fi

if [ -f "$HOME/.bashrc" ] && grep -q "starship init" "$HOME/.bashrc"; then
    read -p "¿Eliminar Starship de la configuración de Bash? (s/n): " confirm_bash
    if [[ "$confirm_bash" == [Ss]* ]]; then
        sed -i '/starship init/d' "$HOME/.bashrc"
        print_message "yellow" "Starship eliminado de la configuración de Bash"
    fi
fi

# Desinstalar Starship
if command -v starship &> /dev/null; then
    read -p "¿Desinstalar completamente Starship del sistema? (s/n): " confirm_uninstall
    if [[ "$confirm_uninstall" == [Ss]* ]]; then
        # Lamentablemente no hay una forma directa de desinstalar Starship instalado vía curl
        # Simplemente eliminamos el binario
        sudo rm -f /usr/local/bin/starship
        print_message "green" "✓ Starship desinstalado completamente"
    else
        print_message "yellow" "Starship permanece instalado en el sistema"
    fi
else
    print_message "yellow" "Starship no está instalado en el sistema"
fi

print_message "green" "✓ Desinstalación de Starship completada"
