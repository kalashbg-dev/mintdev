#!/bin/bash

# Script de instalación para Ranger (explorador de archivos en terminal) en Linux Mint

# Obtener directorio del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../lib/common.sh"

print_message "blue" "===== INSTALANDO Y CONFIGURANDO RANGER ====="
if ! is_installed ranger; then
    sudo apt install -y ranger highlight caca-utils w3m poppler-utils mediainfo
    check_success "Instalación de Ranger y dependencias"
else
    print_message "yellow" "Ranger ya está instalado"
fi

# Crear directorio de configuración
ensure_dir "$HOME/.config/ranger"

# Generar configuración por defecto si no existe
if [ ! -f "$HOME/.config/ranger/rc.conf" ]; then
    print_message "yellow" "Generando archivos de configuración para Ranger..."
    ranger --copy-config=all
    check_success "Generación de archivos de configuración"
fi

# Configurar Ranger según el tema seleccionado
print_message "yellow" "Configurando Ranger para el tema $THEME_NAME..."

# Modificar configuración según el tema
case $THEME_NAME in
    "tokyo-night" | "catppuccin" | "nord" | "dracula")
        # Para temas oscuros, usar configuración específica
        sed -i 's/set colorscheme default/set colorscheme snowfall/g' "$HOME/.config/ranger/rc.conf"
        sed -i 's/set preview_images false/set preview_images true/g' "$HOME/.config/ranger/rc.conf"
        sed -i 's/set draw_borders none/set draw_borders both/g' "$HOME/.config/ranger/rc.conf"
        ;;
    "gruvbox")
        # Para Gruvbox
        sed -i 's/set colorscheme default/set colorscheme jungle/g' "$HOME/.config/ranger/rc.conf"
        sed -i 's/set preview_images false/set preview_images true/g' "$HOME/.config/ranger/rc.conf"
        sed -i 's/set draw_borders none/set draw_borders both/g' "$HOME/.config/ranger/rc.conf"
        ;;
    *)
        # Configuración predeterminada
        sed -i 's/set preview_images false/set preview_images true/g' "$HOME/.config/ranger/rc.conf"
        sed -i 's/set draw_borders none/set draw_borders both/g' "$HOME/.config/ranger/rc.conf"
        ;;
esac

# Crear script personalizado para vistas previas
cat > "$HOME/.config/ranger/scope.sh.custom" << 'EOF'
#!/usr/bin/env bash

# Configuración personalizada para scope.sh de Ranger
# Script para proporcionar vistas previas mejoradas en Ranger

set -o noclobber -o noglob -o nounset -o pipefail
IFS=$'\n'

# Ruta del archivo
FILE_PATH="${1}"
# Tamaño máximo de la vista previa en bytes
MAX_BYTES=262143
# Altura en líneas de la vista previa para texto
PREVIEW_HEIGHT=30
# Anchura en columnas de la vista previa para texto
PREVIEW_WIDTH=80

handle_extension() {
    case "${FILE_EXTENSION_LOWER}" in
        # Archivos de texto
        txt|md|conf|ini|yaml|yml|json|xml|toml|csv|log)
            bat --color=always --style=numbers --line-range=:500 "${FILE_PATH}" && exit 5
            ;;
        # Código fuente
        js|ts|jsx|tsx|py|c|cpp|h|hpp|sh|bash|zsh|java|kt|rs|go|rb|php|html|css|scss)
            bat --color=always --style=numbers --line-range=:500 "${FILE_PATH}" && exit 5
            ;;
        # Documentos
        pdf)
            pdftotext -l 10 -nopgbrk -q -- "${FILE_PATH}" - | head -500 && exit 5
            ;;
        # Archivos comprimidos
        zip|jar|war|ear|oxt)
            unzip -l "${FILE_PATH}" | head -20 && exit 5
            ;;
        tar|gz|bz2|xz)
            tar -tf "${FILE_PATH}" | head -20 && exit 5
            ;;
        # Imágenes
        bmp|jpg|jpeg|png|gif|webp)
            exiftool "${FILE_PATH}" | head -20 && exit 5
            ;;
        # Audio
        mp3|m4a|ogg|flac|wav|aac)
            mediainfo "${FILE_PATH}" | head -20 && exit 5
            ;;
        # Video
        mp4|mkv|avi|mov|wmv)
            mediainfo "${FILE_PATH}" | head -20 && exit 5
            ;;
    esac
}

handle_mime() {
    case "${MIMETYPE}" in
        # Texto
        text/*)
            bat --color=always --style=numbers --line-range=:500 "${FILE_PATH}" && exit 5
            ;;
        # Imágenes
        image/*)
            exiftool "${FILE_PATH}" | head -20 && exit 5
            ;;
        # Video
        video/*)
            mediainfo "${FILE_PATH}" | head -20 && exit 5
            ;;
        # Audio
        audio/*)
            mediainfo "${FILE_PATH}" | head -20 && exit 5
            ;;
        # Documentos
        application/pdf)
            pdftotext -l 10 -nopgbrk -q -- "${FILE_PATH}" - | head -500 && exit 5
            ;;
        # Documentos de Office
        application/vnd.openxmlformats-officedocument.*|application/vnd.oasis.opendocument.*)
            strings "${FILE_PATH}" | head -20 && exit 5
            ;;
    esac
}

FILE_EXTENSION_LOWER="$(echo ${FILE_PATH##*.} | tr '[:upper:]' '[:lower:]')"
MIMETYPE="$( file --dereference --brief --mime-type -- "${FILE_PATH}" )"

handle_extension
handle_mime

exit 1
EOF

# Hacer ejecutable el script personalizado
chmod +x "$HOME/.config/ranger/scope.sh.custom"

# Configurar alias en .zshrc y .bashrc si existen
if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q "alias ranger=" "$HOME/.zshrc"; then
        echo "" >> "$HOME/.zshrc"
        echo "# Alias para ranger" >> "$HOME/.zshrc"
        echo "alias r='ranger'" >> "$HOME/.zshrc"
    fi
fi

if [ -f "$HOME/.bashrc" ]; then
    if ! grep -q "alias ranger=" "$HOME/.bashrc"; then
        echo "" >> "$HOME/.bashrc"
        echo "# Alias para ranger" >> "$HOME/.bashrc"
        echo "alias r='ranger'" >> "$HOME/.bashrc"
    fi
fi

print_message "green" "✓ Ranger instalado y configurado correctamente"
print_message "yellow" "Para usar Ranger, ejecuta 'ranger' o 'r' (alias) en tu terminal"
print_message "yellow" "Atajos importantes:"
print_message "yellow" "  h/j/k/l     - Navegar (izquierda/abajo/arriba/derecha)"
print_message "yellow" "  q           - Salir"
print_message "yellow" "  i           - Ver archivo"
print_message "yellow" "  E           - Editar archivo"
print_message "yellow" "  /           - Buscar"
print_message "yellow" "  zh          - Mostrar archivos ocultos"
print_message "yellow" "  S           - Terminal en el directorio actual"
