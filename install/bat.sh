#!/bin/bash

# Script de instalación para Bat (alternativa moderna a 'cat') en Linux Mint

# Obtener directorio del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../lib/common.sh"

print_message "blue" "===== INSTALANDO Y CONFIGURANDO BAT ====="
if ! is_installed bat; then
    sudo apt install -y bat
    check_success "Instalación de Bat"
    
    # En algunas distribuciones, el binario de bat se llama batcat
    if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
        print_message "yellow" "Creando enlace simbólico para bat..."
        sudo ln -s /usr/bin/batcat /usr/local/bin/bat
    fi
else
    print_message "yellow" "Bat ya está instalado"
fi

# Crear directorio de configuración
ensure_dir "$HOME/.config/bat"

# Configurar Bat según el tema seleccionado
print_message "yellow" "Configurando Bat para el tema $THEME_NAME..."

# Crear archivo de configuración
cat > "$HOME/.config/bat/config" << EOF
# Archivo de configuración para Bat generado por omakub-mint-version
# Tema actual: $THEME_NAME

# Sintaxis
--map-syntax "*.conf:INI"
--map-syntax ".gitignore:Git Ignore"
--map-syntax ".env:DotENV"

# Estilo
--style="numbers,changes,header"
EOF

# Configurar tema específico
case $THEME_NAME in
    "tokyo-night")
        echo "--theme=\"Tokyo-Night\"" >> "$HOME/.config/bat/config"
        ;;
    "catppuccin")
        echo "--theme=\"Catppuccin-mocha\"" >> "$HOME/.config/bat/config"
        ;;
    "nord")
        echo "--theme=\"Nord\"" >> "$HOME/.config/bat/config"
        ;;
    "gruvbox")
        echo "--theme=\"gruvbox-dark\"" >> "$HOME/.config/bat/config"
        ;;
    "dracula")
        echo "--theme=\"Dracula\"" >> "$HOME/.config/bat/config"
        ;;
    *)
        # Tema predeterminado
        echo "--theme=\"ansi\"" >> "$HOME/.config/bat/config"
        ;;
esac

# Descargar y configurar temas personalizados
print_message "yellow" "Descargando temas adicionales para Bat..."
ensure_dir "$HOME/.config/bat/themes"

# Descargar paquete de temas populares
git clone --depth=1 https://github.com/catppuccin/bat.git /tmp/mint-dev-setup/bat-themes-catppuccin
cp -r /tmp/mint-dev-setup/bat-themes-catppuccin/themes/* "$HOME/.config/bat/themes/"

git clone --depth=1 https://github.com/enkia/enki-theme.git /tmp/mint-dev-setup/bat-themes-tokyo
cp -r /tmp/mint-dev-setup/bat-themes-tokyo/bat/Tokyo-Night.tmTheme "$HOME/.config/bat/themes/"

# Compilar temas de bat
bat cache --build

# Configurar alias en .zshrc y .bashrc si existen
if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q "alias cat=" "$HOME/.zshrc"; then
        echo "" >> "$HOME/.zshrc"
        echo "# Alias para bat" >> "$HOME/.zshrc"
        echo "alias cat='bat -p'" >> "$HOME/.zshrc"
        echo "alias less='bat --paging=always'" >> "$HOME/.zshrc"
    fi
fi

if [ -f "$HOME/.bashrc" ]; then
    if ! grep -q "alias cat=" "$HOME/.bashrc"; then
        echo "" >> "$HOME/.bashrc"
        echo "# Alias para bat" >> "$HOME/.bashrc"
        echo "alias cat='bat -p'" >> "$HOME/.bashrc"
        echo "alias less='bat --paging=always'" >> "$HOME/.bashrc"
    fi
fi

print_message "green" "✓ Bat instalado y configurado correctamente"
print_message "yellow" "Para usar Bat, ejecuta 'bat archivo.txt' en tu terminal o usa 'cat' (ahora es un alias de bat)"
print_message "yellow" "Para mostrar archivos sin números de línea, usa 'bat -p archivo.txt'"
