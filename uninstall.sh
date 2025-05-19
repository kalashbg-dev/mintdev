#!/bin/bash

# Script principal de desinstalación para omakub-mint-version
# Inspirado en el proyecto Omakub (https://github.com/basecamp/omakub)

# Variables
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LOG_FILE="$HOME/mint-dev-uninstall.log"

# Al inicio del script, después de definir las variables iniciales
source "$SCRIPT_DIR/lib/logger.sh"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/idempotence.sh"
source "$SCRIPT_DIR/lib/banner.sh"

# Inicializar sistema de registro
init_logger

# Iniciar registro de log
exec > >(tee -a "$LOG_FILE") 2>&1
echo "$(date) - Iniciando desinstalación de componentes"

# Colores para mensajes
GREEN="\e[32m"
BLUE="\e[34m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

# Función para imprimir mensajes
print_message() {
    local color=$1
    local message=$2
    
    case $color in
        "green") echo -e "${GREEN}$message${RESET}" ;;
        "blue") echo -e "${BLUE}$message${RESET}" ;;
        "yellow") echo -e "${YELLOW}$message${RESET}" ;;
        "red") echo -e "${RED}$message${RESET}" ;;
        *) echo "$message" ;;
    esac
}

# Banner de bienvenida
clear
# Reemplazar el banner actual con el nuevo
show_uninstall_banner

print_message "blue" "======================================================"
print_message "blue" "     Linux Mint Cinnamon 22.1 - Desinstalación"
print_message "blue" "======================================================"
print_message "yellow" "Este script desinstalará componentes seleccionados."
print_message "blue" "======================================================"
echo ""

# Menú de desinstalación
echo "¿Qué componentes deseas desinstalar?"
echo ""
echo "Aplicaciones de desarrollo:"
echo "1) Visual Studio Code"
echo "2) Docker y Docker Compose"
echo "3) GitHub CLI"
echo ""
echo "Bases de datos:"
echo "4) MongoDB"
echo "5) PostgreSQL"
echo ""
echo "Aplicaciones de productividad:"
echo "6) Spotify"
echo "7) LibreOffice"
echo "8) Plank (dock)"
echo "9) Ulauncher"
echo "10) Variety (wallpapers)"
echo ""
echo "Terminal y configuraciones:"
echo "11) Conky (monitor del sistema)"
echo "12) Alacritty (emulador de terminal)"
echo "13) Zsh y Oh My Zsh"
echo "14) Personalización del escritorio (restaurar configuración por defecto)"
echo "15) Todos los componentes"
echo "0) Salir sin desinstalar"
echo ""

# Solicitar selección
read -p "Ingresa el número del componente a desinstalar (o varios separados por espacios): " choices

# Verificar si el usuario eligió salir
if [[ "$choices" == "0" ]]; then
    print_message "yellow" "Saliendo sin realizar cambios."
    exit 0
fi

# Función para desinstalar un componente
desinstalar_componente() {
    local componente=$1
    local script_path=""
    local nombre_componente=""

    case $componente in
        1) script_path="$SCRIPT_DIR/uninstall/app-vscode.sh"; nombre_componente="vscode" ;;
        2) script_path="$SCRIPT_DIR/uninstall/docker.sh"; nombre_componente="docker" ;;
        3) script_path="$SCRIPT_DIR/uninstall/app-github-cli.sh"; nombre_componente="github-cli" ;;
        4) script_path="$SCRIPT_DIR/uninstall/app-mongodb.sh"; nombre_componente="mongodb" ;;
        5) script_path="$SCRIPT_DIR/uninstall/app-postgresql.sh"; nombre_componente="postgresql" ;;
        6) script_path="$SCRIPT_DIR/uninstall/app-spotify.sh"; nombre_componente="spotify" ;;
        7) script_path="$SCRIPT_DIR/uninstall/app-libreoffice.sh"; nombre_componente="libreoffice" ;;
        8) script_path="$SCRIPT_DIR/uninstall/app-plank.sh"; nombre_componente="plank" ;;
        9) script_path="$SCRIPT_DIR/uninstall/app-ulauncher.sh"; nombre_componente="ulauncher" ;;
        10) script_path="$SCRIPT_DIR/uninstall/app-variety.sh"; nombre_componente="variety" ;;
        11) script_path="$SCRIPT_DIR/uninstall/app-conky.sh"; nombre_componente="conky" ;;
        12) script_path="$SCRIPT_DIR/uninstall/app-alacritty.sh"; nombre_componente="alacritty" ;;
        13) script_path="$SCRIPT_DIR/uninstall/app-zsh.sh"; nombre_componente="zsh" ;;
        14) script_path="$SCRIPT_DIR/uninstall/desktop-config.sh"; nombre_componente="desktop-config" ;;
        *) print_message "red" "Opción no válida: $componente"
           return 1 ;;
    esac

    # Antes de desinstalar un componente, verificar si está instalado
    if ! is_component_installed "$nombre_componente"; then
        print_message "yellow" "El componente $nombre_componente no está instalado, omitiendo desinstalación"
        return 0
    fi
    
    if [ -f "$script_path" ]; then
        print_message "blue" "Desinstalando componente $componente..."
        chmod +x "$script_path"
        bash "$script_path"
        if [ $? -eq 0 ]; then
            print_message "green" "✓ Componente $componente desinstalado correctamente"
            # Después de desinstalar un componente exitosamente
            mark_component_uninstalled "$nombre_componente"
        else
            print_message "red" "✗ Error al desinstalar componente $componente"
        fi
    else
        print_message "red" "Script de desinstalación no encontrado: $script_path"
        return 1
    fi
}

# Desinstalar todos los componentes si se seleccionó la opción 15
if [[ "$choices" == *"15"* ]]; then
    print_message "blue" "Desinstalando todos los componentes..."
    for i in {1..14}; do
        desinstalar_componente $i
    done
else
    # Desinstalar componentes seleccionados
    for choice in $choices; do
        desinstalar_componente $choice
    done
fi

print_message "blue" "======================================================"
print_message "green" "✓ DESINSTALACIÓN COMPLETA"
print_message "blue" "======================================================"
print_message "yellow" "Algunos cambios pueden requerir reiniciar la sesión."
print_message "blue" "======================================================"
