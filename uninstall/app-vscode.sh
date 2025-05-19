#!/bin/bash

# Script de desinstalación para Visual Studio Code en Linux Mint

# Obtener directorio del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/idempotence.sh"
source "$SCRIPT_DIR/lib/logger.sh"

print_message "blue" "===== DESINSTALANDO VISUAL STUDIO CODE ====="
log_message "INFO" "Iniciando desinstalación de Visual Studio Code"

# Confirmar desinstalación
read -p "¿Estás seguro de que deseas desinstalar Visual Studio Code? (s/n): " confirm
if [[ "$confirm" != [Ss]* ]]; then
    print_message "yellow" "Desinstalación de Visual Studio Code cancelada."
    log_message "INFO" "Desinstalación de Visual Studio Code cancelada por el usuario"
    exit 0
fi

# Desinstalar VS Code
if is_installed code; then
    print_message "yellow" "Desinstalando Visual Studio Code..."
    log_message "INFO" "Desinstalando paquete de Visual Studio Code"
    sudo apt purge --auto-remove -y code
    check_success "Desinstalación de Visual Studio Code"
    log_message "INFO" "Visual Studio Code desinstalado correctamente"
else
    print_message "yellow" "Visual Studio Code no está instalado"
    log_message "INFO" "Visual Studio Code no está instalado, omitiendo desinstalación"
fi

# Eliminar repositorio y clave
if [ -f /etc/apt/sources.list.d/vscode.list ]; then
    print_message "yellow" "Eliminando repositorio de Visual Studio Code..."
    log_message "INFO" "Eliminando repositorio de Visual Studio Code"
    sudo rm -f /etc/apt/sources.list.d/vscode.list
    sudo rm -f /etc/apt/trusted.gpg.d/packages.microsoft.gpg
    sudo apt update
    check_success "Eliminación del repositorio de Visual Studio Code"
    log_message "INFO" "Repositorio de Visual Studio Code eliminado correctamente"
fi

# Eliminar configuración
if [ -d "$HOME/.config/Code" ]; then
    read -p "¿Deseas eliminar la configuración de Visual Studio Code? (s/n): " confirm_config
    if [[ "$confirm_config" == [Ss]* ]]; then
        print_message "yellow" "Eliminando configuración de Visual Studio Code..."
        log_message "INFO" "Eliminando configuración de Visual Studio Code"
        rm -rf "$HOME/.config/Code"
        check_success "Eliminación de la configuración de Visual Studio Code"
        log_message "INFO" "Configuración de Visual Studio Code eliminada correctamente"
    else
        print_message "yellow" "Conservando configuración de Visual Studio Code"
        log_message "INFO" "Configuración de Visual Studio Code conservada por decisión del usuario"
    fi
fi

# Eliminar extensiones
if [ -d "$HOME/.vscode" ]; then
    read -p "¿Deseas eliminar las extensiones de Visual Studio Code? (s/n): " confirm_ext
    if [[ "$confirm_ext" == [Ss]* ]]; then
        print_message "yellow" "Eliminando extensiones de Visual Studio Code..."
        log_message "INFO" "Eliminando extensiones de Visual Studio Code"
        rm -rf "$HOME/.vscode"
        check_success "Eliminación de extensiones de Visual Studio Code"
        log_message "INFO" "Extensiones de Visual Studio Code eliminadas correctamente"
    else
        print_message "yellow" "Conservando extensiones de Visual Studio Code"
        log_message "INFO" "Extensiones de Visual Studio Code conservadas por decisión del usuario"
    fi
fi

# Marcar el componente como desinstalado
mark_component_uninstalled "vscode"
log_message "INFO" "Visual Studio Code marcado como desinstalado en el sistema de idempotencia"

print_message "green" "✓ Visual Studio Code ha sido desinstalado correctamente"
log_message "INFO" "Desinstalación de Visual Studio Code completada"
