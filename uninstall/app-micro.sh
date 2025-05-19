#!/bin/bash

# Script de desinstalación para Micro editor en Linux Mint

# Variables y funciones
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."
source "$SCRIPT_DIR/lib/common.sh"

print_message "blue" "===== DESINSTALANDO MICRO EDITOR ====="

# Confirmar desinstalación
read -p "¿Estás seguro de que deseas desinstalar Micro editor? (s/n): " confirm
if [[ "$confirm" != [Ss]* ]]; then
    print_message "yellow" "Desinstalación de Micro editor cancelada."
    exit 0
fi

# Eliminar configuración de Micro
if [ -d "$HOME/.config/micro" ]; then
    read -p "¿Eliminar archivos de configuración de Micro? (s/n): " confirm_config
    if [[ "$confirm_config" == [Ss]* ]]; then
        rm -rf "$HOME/.config/micro"
        print_message "yellow" "Archivos de configuración de Micro eliminados"
    fi
fi

# Desinstalar Micro
if command -v micro &> /dev/null; then
    read -p "¿Desinstalar completamente Micro del sistema? (s/n): " confirm_uninstall
    if [[ "$confirm_uninstall" == [Ss]* ]]; then
        # Si fue instalado a través del script
        if [ -f "/usr/local/bin/micro" ]; then
            sudo rm -f /usr/local/bin/micro
            print_message "green" "✓ Micro desinstalado de /usr/local/bin"
        # Si fue instalado a través de apt
        elif dpkg -l | grep -q "micro"; then
            sudo apt remove --purge -y micro
            sudo apt autoremove -y
            print_message "green" "✓ Micro desinstalado a través de apt"
        else
            print_message "yellow" "No se pudo determinar cómo fue instalado Micro"
            read -p "¿Intentar eliminar manualmente el binario de Micro? (s/n): " confirm_manual
            if [[ "$confirm_manual" == [Ss]* ]]; then
                sudo rm -f $(which micro)
                print_message "green" "✓ Binario de Micro eliminado manualmente"
            fi
        fi
    else
        print_message "yellow" "Micro permanece instalado en el sistema"
    fi
else
    print_message "yellow" "Micro no está instalado en el sistema"
fi

print_message "green" "✓ Desinstalación de Micro completada"
