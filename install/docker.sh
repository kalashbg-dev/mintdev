#!/bin/bash

# Script de instalación para Docker y Docker Compose en Linux Mint

# Obtener directorio del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/security.sh"
source "$SCRIPT_DIR/../lib/idempotence.sh"

# Verificar si el componente ya está instalado
if is_component_installed "docker"; then
    print_message "yellow" "Docker ya está instalado"
    log_message "INFO" "Docker ya está instalado, omitiendo instalación"
    exit 0
fi

print_message "blue" "===== INSTALANDO DOCKER Y DOCKER COMPOSE ====="

# Actualizar la sección de instalación para usar el sistema de registro
if ! is_installed docker.io; then
    log_message "INFO" "Iniciando instalación de Docker y Docker Compose"
    sudo apt install -y docker.io docker-compose
    check_success "Instalación de Docker y Docker Compose"
    log_message "INFO" "Docker y Docker Compose instalados correctamente"
    
    # Configurar Docker para iniciar con el sistema
    sudo systemctl enable docker --now
    check_success "Configuración de Docker para iniciar con el sistema"
    log_message "INFO" "Docker configurado para iniciar con el sistema"
    
    # Añadir usuario actual al grupo docker
    sudo usermod -aG docker "$USER"
    check_success "Añadir usuario al grupo docker"
    log_message "INFO" "Usuario añadido al grupo docker"
    
    print_message "yellow" "NOTA: Necesitarás cerrar sesión y volver a iniciarla para que la pertenencia al grupo docker tenga efecto"
    log_message "WARNING" "Es necesario cerrar sesión para que los cambios en el grupo docker tengan efecto"
else
    print_message "yellow" "Docker ya está instalado"
    log_message "INFO" "Docker ya está instalado, verificando configuración"
    
    # Asegurar que el usuario esté en el grupo docker
    if ! groups "$USER" | grep -q '\bdocker\b'; then
        sudo usermod -aG docker "$USER"
        print_message "yellow" "Usuario añadido al grupo docker. Necesitarás cerrar sesión y volver a iniciarla para que esto tenga efecto."
        log_message "INFO" "Usuario añadido al grupo docker"
    else
        log_message "INFO" "El usuario ya pertenece al grupo docker"
    fi
fi

# Al final del script, marcar el componente como instalado
mark_component_installed "docker"
log_message "INFO" "Docker marcado como instalado en el sistema de idempotencia"
