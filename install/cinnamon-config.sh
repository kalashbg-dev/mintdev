#!/bin/bash

# Script de configuración para el entorno Cinnamon en Linux Mint

# Obtener directorio del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../lib/common.sh"

print_message "blue" "===== CONFIGURANDO CINNAMON ====="

# Personalizar tema según la selección
case $THEME_NAME in
    "tokyo-night")
        print_message "blue" "Configurando tema Tokyo Night para Cinnamon..."
        
        # Comprobar si el tema está instalado, si no, instalarlo
        if [ ! -d "/usr/share/themes/TokyoNight" ] && [ ! -d "$HOME/.themes/TokyoNight" ]; then
            print_message "yellow" "Descargando tema Tokyo Night..."
            ensure_dir "$HOME/.themes"
            git clone https://github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme.git /tmp/mint-dev-setup/tokyo-night
            cp -r /tmp/mint-dev-setup/tokyo-night/themes/* "$HOME/.themes/"
            check_success "Descarga e instalación del tema Tokyo Night"
        fi
        
        # Establecer tema y configuraciones
        gsettings set org.cinnamon.theme name "TokyoNight-Dark-B"
        gsettings set org.cinnamon.desktop.interface gtk-theme "TokyoNight-Dark-B"
        gsettings set org.cinnamon.desktop.wm.preferences theme "TokyoNight-Dark-B"
        gsettings set org.cinnamon.desktop.interface icon-theme "Papirus-Dark"
        gsettings set org.cinnamon.desktop.interface cursor-theme "Bibata-Modern-Ice"
        ;;
        
    "catppuccin")
        print_message "magenta" "Configurando tema Catppuccin para Cinnamon..."
        
        # Comprobar si el tema está instalado, si no, instalarlo
        if [ ! -d "/usr/share/themes/Catppuccin-Mocha" ] && [ ! -d "$HOME/.themes/Catppuccin-Mocha" ]; then
            print_message "yellow" "Descargando tema Catppuccin..."
            ensure_dir "$HOME/.themes"
            git clone https://github.com/catppuccin/gtk.git /tmp/mint-dev-setup/catppuccin
            cp -r /tmp/mint-dev-setup/catppuccin/themes/* "$HOME/.themes/"
            check_success "Descarga e instalación del tema Catppuccin"
        fi
        
        # Establecer tema y configuraciones
        gsettings set org.cinnamon.theme name "Catppuccin-Mocha"
        gsettings set org.cinnamon.desktop.interface gtk-theme "Catppuccin-Mocha"
        gsettings set org.cinnamon.desktop.wm.preferences theme "Catppuccin-Mocha"
        gsettings set org.cinnamon.desktop.interface icon-theme "Papirus-Dark"
        gsettings set org.cinnamon.desktop.interface cursor-theme "Bibata-Modern-Classic"
        ;;
        
    "nord")
        print_message "cyan" "Configurando tema Nord para Cinnamon..."
        
        # Comprobar si el tema está instalado, si no, instalarlo
        if [ ! -d "/usr/share/themes/Nordic" ] && [ ! -d "$HOME/.themes/Nordic" ]; then
            print_message "yellow" "Descargando tema Nordic..."
            ensure_dir "$HOME/.themes"
            git clone https://github.com/EliverLara/Nordic.git /tmp/mint-dev-setup/nordic
            cp -r /tmp/mint-dev-setup/nordic "$HOME/.themes/"
            check_success "Descarga e instalación del tema Nordic"
        fi
        
        # Establecer tema y configuraciones
        gsettings set org.cinnamon.theme name "Nordic"
        gsettings set org.cinnamon.desktop.interface gtk-theme "Nordic"
        gsettings set org.cinnamon.desktop.wm.preferences theme "Nordic"
        gsettings set org.cinnamon.desktop.interface icon-theme "Papirus"
        gsettings set org.cinnamon.desktop.interface cursor-theme "Nordzy-cursors"
        ;;
        
    "gruvbox")
        print_message "yellow" "Configurando tema Gruvbox para Cinnamon..."
        
        # Comprobar si el tema está instalado, si no, instalarlo
        if [ ! -d "/usr/share/themes/Gruvbox-Material" ] && [ ! -d "$HOME/.themes/Gruvbox-Material" ]; then
            print_message "yellow" "Descargando tema Gruvbox..."
            ensure_dir "$HOME/.themes"
            git clone https://github.com/TheGreatMcPain/gruvbox-material-gtk.git /tmp/mint-dev-setup/gruvbox
            cp -r /tmp/mint-dev-setup/gruvbox/themes/* "$HOME/.themes/"
            check_success "Descarga e instalación del tema Gruvbox"
        fi
        
        # Establecer tema y configuraciones
        gsettings set org.cinnamon.theme name "Gruvbox-Material"
        gsettings set org.cinnamon.desktop.interface gtk-theme "Gruvbox-Material"
        gsettings set org.cinnamon.desktop.wm.preferences theme "Gruvbox-Material"
        gsettings set org.cinnamon.desktop.interface icon-theme "Papirus"
        gsettings set org.cinnamon.desktop.interface cursor-theme "Bibata-Original-Classic"
        ;;
        
    "dracula")
        print_message "magenta" "Configurando tema Dracula para Cinnamon..."
        
        # Comprobar si el tema está instalado, si no, instalarlo
        if [ ! -d "/usr/share/themes/Dracula" ] && [ ! -d "$HOME/.themes/Dracula" ]; then
            print_message "yellow" "Descargando tema Dracula..."
            ensure_dir "$HOME/.themes"
            git clone https://github.com/dracula/gtk.git /tmp/mint-dev-setup/dracula
            cp -r /tmp/mint-dev-setup/dracula/gtk-3.0 "$HOME/.themes/Dracula"
            check_success "Descarga e instalación del tema Dracula"
        fi
        
        # Establecer tema y configuraciones
        gsettings set org.cinnamon.theme name "Dracula"
        gsettings set org.cinnamon.desktop.interface gtk-theme "Dracula"
        gsettings set org.cinnamon.desktop.wm.preferences theme "Dracula"
        gsettings set org.cinnamon.desktop.interface icon-theme "Papirus-Dark"
        gsettings set org.cinnamon.desktop.interface cursor-theme "Bibata-Modern-Ice"
        ;;
        
    *)
        print_message "yellow" "No se ha seleccionado un tema válido, usando configuraciones predeterminadas"
        ;;
esac

# Instalar temas de iconos necesarios
print_message "blue" "Instalando temas de iconos..."
if ! is_installed papirus-icon-theme; then
    sudo add-apt-repository -y ppa:papirus/papirus
    sudo apt update && sudo apt install -y papirus-icon-theme
    check_success "Instalación del tema de iconos Papirus"
fi

# Instalar cursores
print_message "blue" "Instalando temas de cursores..."
if [ ! -d "/usr/share/icons/Bibata-Modern-Ice" ] && [ ! -d "$HOME/.icons/Bibata-Modern-Ice" ]; then
    ensure_dir "$HOME/.icons"
    wget -O /tmp/mint-dev-setup/bibata-cursors.tar.gz https://github.com/ful1e5/Bibata_Cursor/releases/download/v2.0.3/Bibata.tar.gz
    tar -xf /tmp/mint-dev-setup/bibata-cursors.tar.gz -C "$HOME/.icons/"
    check_success "Instalación de cursores Bibata"
fi

# Instalar fuentes
print_message "blue" "Instalando fuentes adicionales..."
if [ ! -f "$HOME/.local/share/fonts/CascadiaCode.ttf" ]; then
    ensure_dir "$HOME/.local/share/fonts"
    wget -O /tmp/mint-dev-setup/cascadia-code.zip https://github.com/microsoft/cascadia-code/releases/download/v2111.01/CascadiaCode-2111.01.zip
    unzip -o /tmp/mint-dev-setup/cascadia-code.zip -d /tmp/mint-dev-setup/cascadia-code
    cp /tmp/mint-dev-setup/cascadia-code/ttf/CascadiaCodePL.ttf "$HOME/.local/share/fonts/CascadiaCode.ttf"
    fc-cache -f -v
    check_success "Instalación de fuentes Cascadia Code"
fi

# Configurar ajustes adicionales de Cinnamon
print_message "blue" "Configurando ajustes adicionales de Cinnamon..."

# Habilitar efectos visuales
gsettings set org.cinnamon desktop-effects true
gsettings set org.cinnamon desktop-effects-on-menus true
gsettings set org.cinnamon desktop-effects-on-dialogs true

# Configuración de la barra de menú
gsettings set org.cinnamon panels-enabled "['1:0:bottom']"
gsettings set org.cinnamon panel-zone-icon-sizes '[{"panelId":1,"left":24,"center":0,"right":24}]'

# Configuración del escritorio
gsettings set org.nemo.desktop desktop-layout 'true:false'
gsettings set org.nemo.desktop show-desktop-icons true
gsettings set org.nemo.desktop font 'Noto Sans 10'

# Configuración de ventanas
gsettings set org.cinnamon.desktop.wm.preferences action-middle-click-titlebar 'minimize'
gsettings set org.cinnamon.desktop.wm.preferences action-scroll-titlebar 'opacity'
gsettings set org.cinnamon.desktop.wm.preferences titlebar-font 'Noto Sans Bold 10'

# Configuración de la fuente
gsettings set org.cinnamon.desktop.interface font-name 'Noto Sans 10'
gsettings set org.cinnamon.desktop.interface document-font-name 'Noto Sans 10'
gsettings set org.cinnamon.desktop.interface monospace-font-name 'JetBrains Mono 10'

check_success "Configuración de ajustes de Cinnamon"

print_message "green" "✓ Configuración de Cinnamon completada"
