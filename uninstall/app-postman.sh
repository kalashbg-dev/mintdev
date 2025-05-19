#!/bin/bash

# Script de desinstalación para Postman en Linux Mint

# Variables y funciones
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."
source "$SCRIPT_DIR/lib/common.sh"

print_message "blue" "===== DESINSTALANDO POSTMAN ====="

# Confirmar desinstalación
read -p "¿Estás seguro de que deseas desinstalar Postman? (s/n): " confirm
if [[ "$confirm" != [Ss]* ]]; then
    print_message "yellow" "Desinstalación de Postman cancelada."
    exit 0
fi

# Eliminar Postman
if [ -d "/opt/Postman" ]; then
    print_message "yellow" "Eliminando Postman..."
    sudo rm -rf /opt/Postman
    print_message "yellow" "Directorio de Postman eliminado"
fi

# Eliminar enlace simbólico
if [ -L "/usr/bin/postman" ]; then
    sudo rm -f /usr/bin/postman
    print_message "yellow" "Enlace simbólico de Postman eliminado"
fi

# Eliminar acceso directo
if [ -f "/usr/share/applications/postman.desktop" ]; then
    sudo rm -f /usr/share/applications/postman.desktop
    print_message "yellow" "Acceso directo de Postman eliminado"
fi

print_message "green" "✓ Desinstalación de Postman completada"
