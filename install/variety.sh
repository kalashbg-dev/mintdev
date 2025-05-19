#!/bin/bash

# Script de instalación para Variety (gestor de fondos de pantalla) en Linux Mint

# Obtener directorio del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../lib/common.sh"

print_message "blue" "===== INSTALANDO Y CONFIGURANDO VARIETY (GESTOR DE FONDOS DE PANTALLA) ====="
if ! is_installed variety; then
    # Añadir repositorio PPA para Variety
    sudo add-apt-repository -y ppa:variety/stable
    sudo apt update && sudo apt install -y variety
    check_success "Instalación de Variety"
else
    print_message "yellow" "Variety ya está instalado"
fi

# Crear directorio de configuración
ensure_dir "$HOME/.config/variety"

# Descargar fondos de pantalla según el tema seleccionado
case $THEME_NAME in
    "tokyo-night")
        print_message "blue" "Configurando fondos de pantalla tipo Tokyo Night..."
        mkdir -p "$HOME/Pictures/Wallpapers/tokyo-night"
        # URLs de fondos de pantalla Tokyo Night
        wget -q -O "$HOME/Pictures/Wallpapers/tokyo-night/tokyo-night-1.jpg" "https://raw.githubusercontent.com/linuxmint/mint-backgrounds-vanessa/master/usr/share/backgrounds/linuxmint/default_background.jpg"
        ;;
    "catppuccin")
        print_message "magenta" "Configurando fondos de pantalla tipo Catppuccin..."
        mkdir -p "$HOME/Pictures/Wallpapers/catppuccin"
        # URLs de fondos de pantalla Catppuccin
        wget -q -O "$HOME/Pictures/Wallpapers/catppuccin/catppuccin-1.jpg" "https://raw.githubusercontent.com/linuxmint/mint-backgrounds-vanessa/master/usr/share/backgrounds/linuxmint/soapbubble.jpg"
        ;;
    "nord")
        print_message "cyan" "Configurando fondos de pantalla tipo Nord..."
        mkdir -p "$HOME/Pictures/Wallpapers/nord"
        # URLs de fondos de pantalla Nord
        wget -q -O "$HOME/Pictures/Wallpapers/nord/nord-1.jpg" "https://raw.githubusercontent.com/linuxmint/mint-backgrounds-vanessa/master/usr/share/backgrounds/linuxmint/vanessa.jpg"
        ;;
    "gruvbox")
        print_message "yellow" "Configurando fondos de pantalla tipo Gruvbox..."
        mkdir -p "$HOME/Pictures/Wallpapers/gruvbox"
        # URLs de fondos de pantalla Gruvbox
        wget -q -O "$HOME/Pictures/Wallpapers/gruvbox/gruvbox-1.jpg" "https://raw.githubusercontent.com/linuxmint/mint-backgrounds-vanessa/master/usr/share/backgrounds/linuxmint/ahorn.jpg"
        ;;
    "dracula")
        print_message "magenta" "Configurando fondos de pantalla tipo Dracula..."
        mkdir -p "$HOME/Pictures/Wallpapers/dracula"
        # URLs de fondos de pantalla Dracula
        wget -q -O "$HOME/Pictures/Wallpapers/dracula/dracula-1.jpg" "https://raw.githubusercontent.com/linuxmint/mint-backgrounds-vanessa/master/usr/share/backgrounds/linuxmint/violet_flower.jpg"
        ;;
    *)
        print_message "yellow" "No se ha seleccionado un tema válido, usando fondos de pantalla predeterminados"
        ;;
esac

# Configurar Variety
cat > "$HOME/.config/variety/variety.conf" << EOF
# Configuración de variety

# Cambia automáticamente el fondo de pantalla
change_enabled = True

# Intervalo de cambio en segundos
change_interval = 3600

# Configuración general
download_enabled = True
download_interval = 86400
download_folder = ~/.config/variety/Downloaded

# Fuentes de fondos de pantalla
sources = [
    {
        "type": "favorites",
        "location": "~/.config/variety/Favorites",
        "selected": True
    },
    {
        "type": "folder",
        "location": "~/Pictures/Wallpapers",
        "selected": True
    }
]

# Opciones de filtrado
min_rating = 4
use_landscape_enabled = True
lightness_enabled = False
min_size_enabled = True
min_size = 80
safe_mode = True

# Opciones de interfaz de usuario
icon = Light
desired_color_enabled = False
desired_color = None
clock_enabled = True
clock_font = Sans 70
clock_date_font = Sans 30
quotes_enabled = True
quotes_font = Sans 20
quotes_text_color = 255, 255, 255
quotes_bg_color = 80, 80, 80, 185
quotes_bg_opacity = 70
quotes_text_shadow = False
quotes_disabled_sources = []
quotes_tags = ""
quotes_authors = ""
quotes_change_enabled = True
quotes_change_interval = 3600
EOF

# Añadir los fondos descargados a la lista de favoritos
case $THEME_NAME in
    "tokyo-night")
        ln -sf "$HOME/Pictures/Wallpapers/tokyo-night" "$HOME/.config/variety/Favorites"
        ;;
    "catppuccin")
        ln -sf "$HOME/Pictures/Wallpapers/catppuccin" "$HOME/.config/variety/Favorites"
        ;;
    "nord")
        ln -sf "$HOME/Pictures/Wallpapers/nord" "$HOME/.config/variety/Favorites"
        ;;
    "gruvbox")
        ln -sf "$HOME/Pictures/Wallpapers/gruvbox" "$HOME/.config/variety/Favorites"
        ;;
    "dracula")
        ln -sf "$HOME/Pictures/Wallpapers/dracula" "$HOME/.config/variety/Favorites"
        ;;
    *)
        print_message "yellow" "No se ha configurado ningún directorio de favoritos"
        ;;
esac

# Crear script de inicio para Variety
cat > "$HOME/.config/autostart/variety.desktop" << EOF
[Desktop Entry]
Type=Application
Name=Variety
Comment=Gestor de fondos de pantalla
Exec=variety
StartupNotify=false
Terminal=false
Categories=Utility;
EOF
chmod +x "$HOME/.config/autostart/variety.desktop"

# Iniciar Variety (sin esperar a que termine)
if pgrep -x "variety" > /dev/null; then
    killall variety
    sleep 1
fi
nohup variety > /dev/null 2>&1 &

check_success "Configuración de Variety"

print_message "green" "✓ Variety instalado y configurado correctamente"
print_message "yellow" "Variety se iniciará automáticamente en el próximo inicio de sesión"
print_message "yellow" "Los fondos de pantalla se cambiarán automáticamente cada hora"
