#!/bin/bash

# Script de instalación para Node.js y npm via NVM en Linux Mint

# Obtener directorio del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../lib/common.sh"

print_message "blue" "===== INSTALANDO NODE.JS Y NPM VIA NVM ====="
if [ ! -d ~/.nvm ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install --lts
    nvm use --lts
    check_success "Instalación de Node.js y npm mediante NVM"
else
    print_message "yellow" "NVM ya está instalado"
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install --lts
fi

# Instalar paquetes npm globales
print_message "blue" "===== INSTALANDO PAQUETES NPM GLOBALES ====="
npm install -g yarn typescript ts-node prettier eslint nodemon
check_success "Instalación de paquetes npm globales"
