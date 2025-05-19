#!/bin/bash

# Script para mostrar una vista previa de un tema

# Obtener directorio del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Cargar módulos necesarios
source "$SCRIPT_DIR/lib/logger.sh"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/theme-manager.sh"
source "$SCRIPT_DIR/lib/banner.sh"

# Inicializar sistema de registro
init_logger

# Mostrar banner
show_themes_banner

print_message "blue" "===== VISTA PREVIA DE TEMA ====="

# Verificar si se proporcionó un tema
if [ $# -eq 0 ]; then
    print_message "yellow" "Uso: $0 <nombre-tema>"
    print_message "yellow" "Temas disponibles:"
    list_available_themes
    exit 1
fi

THEME_NAME=$1

# Mostrar vista previa del tema
preview_theme "$THEME_NAME"

exit 0
