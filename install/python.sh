#!/bin/bash

# Script de instalación para Python y librerías de ciencia de datos en Linux Mint

# Obtener directorio del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../lib/common.sh"

print_message "blue" "===== INSTALANDO PYTHON Y HERRAMIENTAS DE CIENCIA DE DATOS ====="
sudo apt install -y python3 python3-pip python3-venv python3-dev
check_success "Instalación de Python"

# Instalar paquetes comunes de Python
print_message "yellow" "Instalando paquetes de Python (esto puede tardar unos minutos)..."
pip3 install --user --upgrade pip
pip3 install --user \
    jupyterlab pandas numpy matplotlib seaborn scikit-learn \
    xgboost openpyxl requests flask django
check_success "Instalación de paquetes de Python"
