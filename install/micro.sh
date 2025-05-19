#!/bin/bash

# Script de instalación para el editor Micro en Linux Mint

# Obtener directorio del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../lib/common.sh"

print_message "blue" "===== INSTALANDO Y CONFIGURANDO MICRO EDITOR ====="

# Verificar si Micro ya está instalado
if command -v micro &> /dev/null; then
    print_message "yellow" "Micro ya está instalado"
else
    print_message "yellow" "Descargando e instalando Micro..."
    # Crear directorio temporal
    mkdir -p /tmp/mint-dev-setup/micro
    cd /tmp/mint-dev-setup/micro
    
    # Descargar la última versión
    curl -s https://api.github.com/repos/zyedidia/micro/releases/latest | \
    grep "linux64-static.tar.gz" | \
    cut -d : -f 2,3 | \
    tr -d \" | \
    wget -qi -
    
    # Extraer y mover a /usr/local/bin
    tar -xzf micro*linux64-static.tar.gz
    sudo mv micro*/micro /usr/local/bin/
    check_success "Instalación de Micro"
    
    # Limpiar
    rm -rf /tmp/mint-dev-setup/micro
fi

# Crear directorios de configuración
ensure_dir "$HOME/.config/micro"
ensure_dir "$HOME/.config/micro/colorschemes"

# Configurar Micro según el tema seleccionado
print_message "yellow" "Configurando Micro para el tema $THEME_NAME..."

# Crear archivo de configuración básico
cat > "$HOME/.config/micro/settings.json" << EOF
{
    "autoclose": true,
    "autoindent": true,
    "autosave": false,
    "colorscheme": "${THEME_NAME,,}",
    "cursorline": true,
    "eofnewline": true,
    "ignorecase": false,
    "indentchar": " ",
    "infobar": true,
    "keepautoindent": false,
    "linter": true,
    "pluginchannels": [
        "https://raw.githubusercontent.com/micro-editor/plugin-channel/master/channel.json"
    ],
    "pluginrepos": [],
    "rmtrailingws": true,
    "ruler": true,
    "savecursor": true,
    "savehistory": true,
    "saveundo": true,
    "scrollbar": false,
    "scrollmargin": 3,
    "scrollspeed": 2,
    "softwrap": false,
    "statusline": true,
    "syntax": true,
    "tabmovement": false,
    "tabsize": 4,
    "tabstospaces": true,
    "termtitle": false,
    "useprimary": true
}
EOF

# Crear esquemas de colores según el tema seleccionado
case $THEME_NAME in
    "tokyo-night")
        cat > "$HOME/.config/micro/colorschemes/tokyo-night.micro" << EOF
color-link default "#a9b1d6,#1a1b26"
color-link comment "#565f89"
color-link identifier "#7aa2f7"
color-link constant "#ff9e64"
color-link constant.number "#ff9e64"
color-link constant.string "#9ece6a"
color-link symbol "#bb9af7"
color-link statement "#bb9af7"
color-link preproc "#7dcfff"
color-link type "#7dcfff"
color-link special "#f7768e"
color-link underlined "#7aa2f7"
color-link error "bold #f7768e"
color-link todo "bold #e0af68"
color-link statusline "#a9b1d6,#24283b"
color-link gutter-error "#f7768e"
color-link gutter-warning "#e0af68"
color-link line-number "#565f89,#1a1b26"
color-link current-line-number "#7aa2f7"
color-link cursor-line "#24283b"
color-link color-column "#24283b"
color-link diff-added "#9ece6a"
color-link diff-modified "#7aa2f7"
color-link diff-deleted "#f7768e"
EOF
        ;;
    "catppuccin")
        cat > "$HOME/.config/micro/colorschemes/catppuccin.micro" << EOF
color-link default "#cdd6f4,#1e1e2e"
color-link comment "#6c7086"
color-link identifier "#89b4fa"
color-link constant "#fab387"
color-link constant.number "#fab387"
color-link constant.string "#a6e3a1"
color-link symbol "#cba6f7"
color-link statement "#cba6f7"
color-link preproc "#89dceb"
color-link type "#89dceb"
color-link special "#f38ba8"
color-link underlined "#89b4fa"
color-link error "bold #f38ba8"
color-link todo "bold #f9e2af"
color-link statusline "#cdd6f4,#313244"
color-link gutter-error "#f38ba8"
color-link gutter-warning "#f9e2af"
color-link line-number "#6c7086,#1e1e2e"
color-link current-line-number "#89b4fa"
color-link cursor-line "#313244"
color-link color-column "#313244"
color-link diff-added "#a6e3a1"
color-link diff-modified "#89b4fa"
color-link diff-deleted "#f38ba8"
EOF
        ;;
    "nord")
        cat > "$HOME/.config/micro/colorschemes/nord.micro" << EOF
color-link default "#d8dee9,#2e3440"
color-link comment "#4c566a"
color-link identifier "#88c0d0"
color-link constant "#d08770"
color-link constant.number "#d08770"
color-link constant.string "#a3be8c"
color-link symbol "#b48ead"
color-link statement "#b48ead"
color-link preproc "#8fbcbb"
color-link type "#8fbcbb"
color-link special "#bf616a"
color-link underlined "#88c0d0"
color-link error "bold #bf616a"
color-link todo "bold #ebcb8b"
color-link statusline "#d8dee9,#3b4252"
color-link gutter-error "#bf616a"
color-link gutter-warning "#ebcb8b"
color-link line-number "#4c566a,#2e3440"
color-link current-line-number "#88c0d0"
color-link cursor-line "#3b4252"
color-link color-column "#3b4252"
color-link diff-added "#a3be8c"
color-link diff-modified "#88c0d0"
color-link diff-deleted "#bf616a"
EOF
        ;;
    "gruvbox")
        cat > "$HOME/.config/micro/colorschemes/gruvbox.micro" << EOF
color-link default "#ebdbb2,#282828"
color-link comment "#928374"
color-link identifier "#83a598"
color-link constant "#fe8019"
color-link constant.number "#fe8019"
color-link constant.string "#b8bb26"
color-link symbol "#d3869b"
color-link statement "#d3869b"
color-link preproc "#8ec07c"
color-link type "#8ec07c"
color-link special "#fb4934"
color-link underlined "#83a598"
color-link error "bold #fb4934"
color-link todo "bold #fabd2f"
color-link statusline "#ebdbb2,#3c3836"
color-link gutter-error "#fb4934"
color-link gutter-warning "#fabd2f"
color-link line-number "#928374,#282828"
color-link current-line-number "#83a598"
color-link cursor-line "#3c3836"
color-link color-column "#3c3836"
color-link diff-added "#b8bb26"
color-link diff-modified "#83a598"
color-link diff-deleted "#fb4934"
EOF
        ;;
    "dracula")
        cat > "$HOME/.config/micro/colorschemes/dracula.micro" << EOF
color-link default "#f8f8f2,#282a36"
color-link comment "#6272a4"
color-link identifier "#8be9fd"
color-link constant "#ffb86c"
color-link constant.number "#ffb86c"
color-link constant.string "#f1fa8c"
color-link symbol "#bd93f9"
color-link statement "#bd93f9"
color-link preproc "#ff79c6"
color-link type "#ff79c6"
color-link special "#ff5555"
color-link underlined "#8be9fd"
color-link error "bold #ff5555"
color-link todo "bold #f1fa8c"
color-link statusline "#f8f8f2,#44475a"
color-link gutter-error "#ff5555"
color-link gutter-warning "#f1fa8c"
color-link line-number "#6272a4,#282a36"
color-link current-line-number "#8be9fd"
color-link cursor-line "#44475a"
color-link color-column "#44475a"
color-link diff-added "#50fa7b"
color-link diff-modified "#8be9fd"
color-link diff-deleted "#ff5555"
EOF
        ;;
    *)
        # Tema predeterminado
        print_message "yellow" "No se ha seleccionado un tema válido, usando configuración predeterminada"
        ;;
esac

# Instalar plugins útiles
print_message "yellow" "Instalando plugins para Micro..."
micro -plugin install fzf
micro -plugin install filemanager
micro -plugin install linter
micro -plugin install jump
micro -plugin install comment
micro -plugin install autofmt
check_success "Instalación de plugins para Micro"

print_message "green" "✓ Micro editor instalado y configurado correctamente"
print_message "yellow" "Para abrir Micro, ejecuta 'micro archivo.txt' en tu terminal"
print_message "yellow" "Atajos importantes:"
print_message "yellow" "  Ctrl+e       - Abrir barra de comandos"
print_message "yellow" "  Ctrl+q       - Salir"
print_message "yellow" "  Ctrl+s       - Guardar"
print_message "yellow" "  Ctrl+f       - Buscar"
print_message "yellow" "  Ctrl+z/y     - Deshacer/Rehacer"
print_message "yellow" "  Alt+/        - Comentar/Descomentar"
print_message "yellow" "  Ctrl+b       - Abrir explorador de archivos"
print_message "yellow" "  Ctrl+p       - Abrir búsqueda difusa (fzf)"
