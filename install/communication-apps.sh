#!/bin/bash

# Script de instalación para aplicaciones de comunicación en Linux Mint
# Incluye: Slack, Telegram y WhatsApp

# Obtener directorio del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../lib/common.sh"

print_message "blue" "===== INSTALANDO APLICACIONES DE COMUNICACIÓN ====="

# Instalar Slack
print_message "yellow" "Instalando Slack..."
if ! is_installed slack-desktop; then
    # Añadir repositorio de Slack
    print_message "yellow" "Añadiendo repositorio de Slack y clave GPG..."
    sudo apt install -y wget gnupg2
    wget -qO - https://packagecloud.io/slacktechnologies/slack/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/slack-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/slack-archive-keyring.gpg] https://packagecloud.io/slacktechnologies/slack/debian/ jessie main" | sudo tee /etc/apt/sources.list.d/slack.list
    
    # Instalar Slack
    sudo apt update && sudo apt install -y slack-desktop
    check_success "Instalación de Slack"
else
    print_message "yellow" "Slack ya está instalado"
fi

# Instalar Telegram
print_message "yellow" "Instalando Telegram..."
if ! is_installed telegram-desktop; then
    sudo apt install -y telegram-desktop
    check_success "Instalación de Telegram"
else
    print_message "yellow" "Telegram ya está instalado"
fi

# Instalar WhatsApp (versión web empaquetada con nativefier)
print_message "yellow" "Instalando WhatsApp Desktop..."
if [ ! -d "/opt/whatsapp-desktop" ]; then
    # Verificar si Node.js y npm están instalados
    if ! command -v npm &> /dev/null; then
        print_message "yellow" "Node.js no está instalado, instalándolo primero..."
        # Nos aseguramos de tener curl
        sudo apt install -y curl
        # Instalamos NVM
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        # Instalamos Node.js
        nvm install --lts
        nvm use --lts
        check_success "Instalación de Node.js"
    fi
    
    # Instalar nativefier
    npm install -g nativefier
    check_success "Instalación de nativefier"
    
    # Crear directorio temporal
    mkdir -p /tmp/mint-dev-setup/whatsapp
    cd /tmp/mint-dev-setup/whatsapp
    
    # Crear aplicación de WhatsApp Web
    print_message "yellow" "Creando aplicación de WhatsApp Web (esto puede tardar unos minutos)..."
    nativefier --name "WhatsApp Desktop" \
              --platform linux \
              --arch x64 \
              --app-version "1.0.0" \
              --width 1200 \
              --height 800 \
              --tray \
              --counter \
              --single-instance \
              --user-agent "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36" \
              "https://web.whatsapp.com" \
              /tmp/mint-dev-setup/whatsapp
    check_success "Creación de la aplicación de WhatsApp Web"
    
    # Instalar en /opt
    sudo mkdir -p /opt/whatsapp-desktop
    sudo cp -r /tmp/mint-dev-setup/whatsapp/"WhatsApp Desktop-linux-x64"/* /opt/whatsapp-desktop/
    
    # Crear enlace simbólico
    sudo ln -sf /opt/whatsapp-desktop/WhatsApp\ Desktop /usr/local/bin/whatsapp-desktop
    
    # Crear entrada de escritorio
    cat > /tmp/mint-dev-setup/whatsapp/whatsapp-desktop.desktop << EOF
[Desktop Entry]
Name=WhatsApp
GenericName=WhatsApp Desktop
Comment=Aplicación de WhatsApp para escritorio
Exec=/opt/whatsapp-desktop/WhatsApp\ Desktop
Terminal=false
Type=Application
Icon=/opt/whatsapp-desktop/resources/app/icon.png
Categories=Network;InstantMessaging;
StartupNotify=true
EOF
    
    sudo mv /tmp/mint-dev-setup/whatsapp/whatsapp-desktop.desktop /usr/share/applications/
    check_success "Creación del acceso directo de WhatsApp"
    
    # Limpiar
    rm -rf /tmp/mint-dev-setup/whatsapp
else
    print_message "yellow" "WhatsApp Desktop ya está instalado"
fi

print_message "green" "✓ Aplicaciones de comunicación instaladas correctamente"
print_message "yellow" "Puedes iniciar las aplicaciones desde el menú de aplicaciones"
