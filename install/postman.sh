#!/bin/bash

# Script de instalación para Postman en Linux Mint

# Obtener directorio del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../lib/common.sh"

print_message "blue" "===== INSTALANDO POSTMAN ====="

# Verificar si Postman ya está instalado
if [ -d "/opt/Postman" ] || [ -f "/usr/bin/postman" ]; then
    print_message "yellow" "Postman ya está instalado"
else
    print_message "yellow" "Descargando Postman..."
    # Crear directorio temporal
    mkdir -p /tmp/mint-dev-setup/postman
    cd /tmp/mint-dev-setup/postman
    
    # Descargar la última versión
    wget -q https://dl.pstmn.io/download/latest/linux64 -O postman.tar.gz
    check_success "Descarga de Postman"
    
    # Extraer y mover a /opt
    print_message "yellow" "Instalando Postman..."
    sudo tar -xzf postman.tar.gz -C /opt
    check_success "Extracción de Postman"
    
    # Crear enlace simbólico
    sudo ln -sf /opt/Postman/Postman /usr/bin/postman
    
    # Crear entrada de escritorio
    cat > /tmp/mint-dev-setup/postman/postman.desktop << EOF
[Desktop Entry]
Name=Postman
GenericName=API Client
X-GNOME-FullName=Postman API Client
Comment=Herramienta para pruebas y documentación de APIs
Keywords=api;rest;client;
Exec=/opt/Postman/Postman
Terminal=false
Type=Application
Icon=/opt/Postman/app/resources/app/assets/icon.png
Categories=Development;Utility;
StartupNotify=true
EOF
    
    sudo mv /tmp/mint-dev-setup/postman/postman.desktop /usr/share/applications/
    check_success "Creación del acceso directo de Postman"
    
    # Limpiar
    rm -rf /tmp/mint-dev-setup/postman
fi

print_message "green" "✓ Postman instalado correctamente"
print_message "yellow" "Puedes iniciar Postman desde el menú de aplicaciones o ejecutando 'postman' en la terminal"
