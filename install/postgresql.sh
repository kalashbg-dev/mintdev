#!/bin/bash

# Script de instalación para PostgreSQL en Linux Mint

# Obtener directorio del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../lib/common.sh"

print_message "blue" "===== INSTALANDO POSTGRESQL ====="
if ! is_installed postgresql; then
    sudo apt install -y postgresql postgresql-contrib
    sudo systemctl enable postgresql
    sudo systemctl start postgresql
    check_success "Instalación y configuración del servicio PostgreSQL"
else
    print_message "yellow" "PostgreSQL ya está instalado"
fi
