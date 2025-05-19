#!/bin/bash

# Script de instalación para Insomnia REST Client en Linux Mint

# Obtener directorio del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/security.sh"
source "$SCRIPT_DIR/../lib/idempotence.sh"

# Verificar si el componente ya está instalado
if is_component_installed "insomnia"; then
    print_message "yellow" "Insomnia ya está instalado"
    log_message "INFO" "Insomnia ya está instalado, omitiendo instalación"
    exit 0
fi

print_message "blue" "===== INSTALANDO INSOMNIA REST CLIENT ====="

# Verificar si Insomnia ya está instalado
if ! command -v insomnia &> /dev/null; then
    log_message "INFO" "Iniciando instalación de Insomnia REST Client"
    
    # Añadir la clave GPG del repositorio
    print_message "yellow" "Añadiendo clave GPG del repositorio..."
    secure_download "https://insomnia.rest/keys/debian-public.key.asc" "/tmp/insomnia-key.asc"
    sudo gpg --dearmor -o /usr/share/keyrings/insomnia-archive-keyring.gpg /tmp/insomnia-key.asc
    
    # Añadir el repositorio
    print_message "yellow" "Añadiendo repositorio de Insomnia..."
    echo "deb [signed-by=/usr/share/keyrings/insomnia-archive-keyring.gpg] https://download.insomnia.rest/debian stable main" | sudo tee /etc/apt/sources.list.d/insomnia.list
    
    # Actualizar e instalar Insomnia
    sudo apt update
    sudo apt install -y insomnia
    check_success "Instalación de Insomnia REST Client"
    log_message "INFO" "Insomnia REST Client instalado correctamente"
else
    print_message "yellow" "Insomnia ya está instalado"
    log_message "INFO" "Insomnia ya está instalado, omitiendo instalación"
fi

print_message "green" "✓ Insomnia REST Client instalado correctamente"
print_message "yellow" "Puedes iniciar Insomnia desde el menú de aplicaciones o ejecutando 'insomnia'"

# Marcar el componente como instalado
mark_component_installed "insomnia"
log_message "INFO" "Insomnia marcado como instalado en el sistema de idempotencia"
