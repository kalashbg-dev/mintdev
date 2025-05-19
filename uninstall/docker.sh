#!/bin/bash

# Script de desinstalación para Docker en Linux Mint

# Obtener directorio del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/idempotence.sh"
source "$SCRIPT_DIR/lib/logger.sh"

print_message "blue" "===== DESINSTALANDO DOCKER ====="
log_message "INFO" "Iniciando desinstalación de Docker"

# Confirmar desinstalación
read -p "¿Estás seguro de que deseas desinstalar Docker? (s/n): " confirm
if [[ "$confirm" != [Ss]* ]]; then
    print_message "yellow" "Desinstalación de Docker cancelada."
    log_message "INFO" "Desinstalación de Docker cancelada por el usuario"
    exit 0
fi

# Detener servicios de Docker
print_message "yellow" "Deteniendo servicios de Docker..."
log_message "INFO" "Deteniendo servicios de Docker"
sudo systemctl stop docker.service
sudo systemctl stop docker.socket
sudo systemctl stop containerd
check_success "Detención de servicios de Docker"
log_message "INFO" "Servicios de Docker detenidos correctamente"

# Desinstalar Docker y Docker Compose
if is_installed docker.io || is_installed docker-ce; then
    print_message "yellow" "Desinstalando Docker y Docker Compose..."
    log_message "INFO" "Desinstalando paquetes de Docker"
    sudo apt purge --auto-remove -y docker.io docker-ce docker-ce-cli containerd.io docker-compose
    check_success "Desinstalación de Docker y Docker Compose"
    log_message "INFO" "Docker y Docker Compose desinstalados correctamente"
else
    print_message "yellow" "Docker no está instalado"
    log_message "INFO" "Docker no está instalado, omitiendo desinstalación"
fi

# Eliminar grupo docker
if getent group docker > /dev/null; then
    print_message "yellow" "Eliminando grupo docker..."
    log_message "INFO" "Eliminando grupo docker"
    sudo groupdel docker
    check_success "Eliminación del grupo docker"
    log_message "INFO" "Grupo docker eliminado correctamente"
fi

# Eliminar archivos de Docker
read -p "¿Deseas eliminar todos los archivos de Docker (imágenes, contenedores, volúmenes)? (s/n): " confirm_files
if [[ "$confirm_files" == [Ss]* ]]; then
    print_message "yellow" "Eliminando archivos de Docker..."
    log_message "INFO" "Eliminando archivos de Docker"
    sudo rm -rf /var/lib/docker
    sudo rm -rf /var/lib/containerd
    check_success "Eliminación de archivos de Docker"
    log_message "INFO" "Archivos de Docker eliminados correctamente"
else
    print_message "yellow" "Conservando archivos de Docker"
    log_message "INFO" "Archivos de Docker conservados por decisión del usuario"
fi

# Marcar el componente como desinstalado
mark_component_uninstalled "docker"
log_message "INFO" "Docker marcado como desinstalado en el sistema de idempotencia"

print_message "green" "✓ Docker ha sido desinstalado correctamente"
log_message "INFO" "Desinstalación de Docker completada"
