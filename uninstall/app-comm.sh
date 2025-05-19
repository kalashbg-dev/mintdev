#!/bin/bash

# Script de desinstalación para aplicaciones de comunicación en Linux Mint

# Variables y funciones
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."
source "$SCRIPT_DIR/lib/common.sh"

print_message "blue" "===== DESINSTALANDO APLICACIONES DE COMUNICACIÓN ====="

# Confirmar desinstalación
read -p "¿Estás seguro de que deseas desinstalar las aplicaciones de comunicación? (s/n): " confirm
if [[ "$confirm" != [Ss]* ]]; then
    print_message "yellow" "Desinstalación de aplicaciones de comunicación cancelada."
    exit 0
fi

# Desinstalar Slack
if is_installed slack-desktop; then
    read -p "¿Desinstalar Slack? (s/n): " confirm_slack
    if [[ "$confirm_slack" == [Ss]* ]]; then
        print_message "yellow" "Desinstalando Slack..."
        sudo apt remove --purge -y slack-desktop
        sudo rm -f /etc/apt/sources.list.d/slack.list
        sudo rm -f /usr/share/keyrings/slack-archive-keyring.gpg
        print_message "green" "✓ Slack desinstalado"
    fi
fi

# Desinstalar Telegram
if is_installed telegram-desktop; then
    read -p "¿Desinstalar Telegram? (s/n): " confirm_telegram
    if [[ "$confirm_telegram" == [Ss]* ]]; then
        print_message "yellow" "Desinstalando Telegram..."
        sudo apt remove --purge -y telegram-desktop
        print_message "green" "✓ Telegram desinstalado"
    fi
fi

# Desinstalar WhatsApp
if [ -d "/opt/whatsapp-desktop" ]; then
    read -p "¿Desinstalar WhatsApp Desktop? (s/n): " confirm_whatsapp
    if [[ "$confirm_whatsapp" == [Ss]* ]]; then
        print_message "yellow" "Desinstalando WhatsApp Desktop..."
        sudo rm -rf /opt/whatsapp-desktop
        sudo rm -f /usr/local/bin/whatsapp-desktop
        sudo rm -f /usr/share/applications/whatsapp-desktop.desktop
        print_message "green" "✓ WhatsApp Desktop desinstalado"
    fi
fi

# Desinstalar Nativefier (si lo instalamos para WhatsApp)
read -p "¿Desinstalar Nativefier (utilizado para crear el cliente de WhatsApp)? (s/n): " confirm_nativefier
if [[ "$confirm_nativefier" == [Ss]* ]]; then
    if command -v npm &> /dev/null; then
        npm uninstall -g nativefier
        print_message "yellow" "Nativefier desinstalado"
    else
        print_message "yellow" "npm no está instalado, no se puede desinstalar Nativefier"
    fi
fi

sudo apt autoremove -y
print_message "green" "✓ Desinstalación de aplicaciones de comunicación completada"
