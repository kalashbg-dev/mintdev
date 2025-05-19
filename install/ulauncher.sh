#!/bin/bash

# Script de instalación para Ulauncher en Linux Mint

# Obtener directorio del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../lib/common.sh"

print_message "blue" "===== INSTALANDO Y CONFIGURANDO ULAUNCHER ====="
if ! is_installed ulauncher; then
    # Añadir repositorio PPA para Ulauncher
    sudo add-apt-repository -y ppa:agornostal/ulauncher
    sudo apt update && sudo apt install -y ulauncher
    check_success "Instalación de Ulauncher"
else
    print_message "yellow" "Ulauncher ya está instalado"
fi

# Crear directorio de configuración
ensure_dir "$HOME/.config/ulauncher/user-themes"

# Configurar tema según la selección
case $THEME_NAME in
    "tokyo-night")
        print_message "blue" "Aplicando tema Tokyo Night para Ulauncher..."
        if [ ! -d "$HOME/.config/ulauncher/user-themes/tokyo-night-ulauncher" ]; then
            ensure_dir "$HOME/.config/ulauncher/user-themes"
            git clone https://github.com/aynp/tokyo-night-ulauncher.git "$HOME/.config/ulauncher/user-themes/tokyo-night-ulauncher"
            check_success "Descarga del tema Tokyo Night para Ulauncher"
            # Configurar el tema
            mkdir -p "$HOME/.config/ulauncher"
            cat > "$HOME/.config/ulauncher/settings.json" << EOF
{
    "clear-previous-query": true,
    "grab-mouse-pointer": false,
    "hotkey-show-app": "<Super>space",
    "render-on-screen": "mouse-pointer-monitor",
    "show-indicator-icon": true,
    "show-recent-apps": true,
    "terminal-command": "",
    "theme-name": "tokyo-night-ulauncher"
}
EOF
        fi
        ;;
    "catppuccin")
        print_message "magenta" "Aplicando tema Catppuccin para Ulauncher..."
        if [ ! -d "$HOME/.config/ulauncher/user-themes/catppuccin-ulauncher" ]; then
            ensure_dir "$HOME/.config/ulauncher/user-themes"
            git clone https://github.com/catppuccin/ulauncher.git "$HOME/.config/ulauncher/user-themes/catppuccin-ulauncher"
            check_success "Descarga del tema Catppuccin para Ulauncher"
            # Configurar el tema
            mkdir -p "$HOME/.config/ulauncher"
            cat > "$HOME/.config/ulauncher/settings.json" << EOF
{
    "clear-previous-query": true,
    "grab-mouse-pointer": false,
    "hotkey-show-app": "<Super>space",
    "render-on-screen": "mouse-pointer-monitor",
    "show-indicator-icon": true,
    "show-recent-apps": true,
    "terminal-command": "",
    "theme-name": "catppuccin-mocha"
}
EOF
        fi
        ;;
    "nord")
        print_message "cyan" "Aplicando tema Nord para Ulauncher..."
        if [ ! -d "$HOME/.config/ulauncher/user-themes/nord-ulauncher" ]; then
            ensure_dir "$HOME/.config/ulauncher/user-themes"
            git clone https://github.com/KarmaComputing/nord-ulauncher.git "$HOME/.config/ulauncher/user-themes/nord-ulauncher"
            check_success "Descarga del tema Nord para Ulauncher"
            # Configurar el tema
            mkdir -p "$HOME/.config/ulauncher"
            cat > "$HOME/.config/ulauncher/settings.json" << EOF
{
    "clear-previous-query": true,
    "grab-mouse-pointer": false,
    "hotkey-show-app": "<Super>space",
    "render-on-screen": "mouse-pointer-monitor",
    "show-indicator-icon": true,
    "show-recent-apps": true,
    "terminal-command": "",
    "theme-name": "nord"
}
EOF
        fi
        ;;
    "gruvbox")
        print_message "yellow" "Aplicando tema Gruvbox para Ulauncher..."
        if [ ! -d "$HOME/.config/ulauncher/user-themes/gruvbox-ulauncher" ]; then
            ensure_dir "$HOME/.config/ulauncher/user-themes"
            git clone https://github.com/SylEleuth/gruvbox-ulauncher.git "$HOME/.config/ulauncher/user-themes/gruvbox-ulauncher"
            check_success "Descarga del tema Gruvbox para Ulauncher"
            # Configurar el tema
            mkdir -p "$HOME/.config/ulauncher"
            cat > "$HOME/.config/ulauncher/settings.json" << EOF
{
    "clear-previous-query": true,
    "grab-mouse-pointer": false,
    "hotkey-show-app": "<Super>space",
    "render-on-screen": "mouse-pointer-monitor",
    "show-indicator-icon": true,
    "show-recent-apps": true,
    "terminal-command": "",
    "theme-name": "gruvbox"
}
EOF
        fi
        ;;
    "dracula")
        print_message "magenta" "Aplicando tema Dracula para Ulauncher..."
        if [ ! -d "$HOME/.config/ulauncher/user-themes/dracula-ulauncher" ]; then
            ensure_dir "$HOME/.config/ulauncher/user-themes"
            git clone https://github.com/dracula/ulauncher.git "$HOME/.config/ulauncher/user-themes/dracula-ulauncher"
            check_success "Descarga del tema Dracula para Ulauncher"
            # Configurar el tema
            mkdir -p "$HOME/.config/ulauncher"
            cat > "$HOME/.config/ulauncher/settings.json" << EOF
{
    "clear-previous-query": true,
    "grab-mouse-pointer": false,
    "hotkey-show-app": "<Super>space",
    "render-on-screen": "mouse-pointer-monitor",
    "show-indicator-icon": true,
    "show-recent-apps": true,
    "terminal-command": "",
    "theme-name": "dracula"
}
EOF
        fi
        ;;
    *)
        print_message "yellow" "No se ha seleccionado un tema válido, usando tema predeterminado"
        ;;
esac

# Crear script de inicio para Ulauncher
cat > "$HOME/.config/autostart/ulauncher.desktop" << EOF
[Desktop Entry]
Type=Application
Name=Ulauncher
Comment=Application launcher for Linux
Exec=ulauncher --hide-window
StartupNotify=false
Terminal=false
Categories=Utility;
EOF
chmod +x "$HOME/.config/autostart/ulauncher.desktop"

# Instalar extensiones útiles para Ulauncher
print_message "yellow" "Instalando extensiones útiles para Ulauncher..."
ensure_dir "$HOME/.local/share/ulauncher/extensions"

# Extensión Calculator
if [ ! -d "$HOME/.local/share/ulauncher/extensions/com.github.ulauncher.ulauncher-calculator" ]; then
    git clone https://github.com/ulauncher/ulauncher-calculator.git "$HOME/.local/share/ulauncher/extensions/com.github.ulauncher.ulauncher-calculator"
fi

# Extensión System
if [ ! -d "$HOME/.local/share/ulauncher/extensions/com.github.iboyperson.ulauncher-system" ]; then
    git clone https://github.com/iboyperson/ulauncher-system.git "$HOME/.local/share/ulauncher/extensions/com.github.iboyperson.ulauncher-system"
fi

# Extensión para búsqueda en Google
if [ ! -d "$HOME/.local/share/ulauncher/extensions/com.github.ulauncher.ulauncher-googlesearch" ]; then
    git clone https://github.com/Ulauncher/ulauncher-googlesearch.git "$HOME/.local/share/ulauncher/extensions/com.github.ulauncher.ulauncher-googlesearch"
fi

check_success "Instalación de extensiones para Ulauncher"

# Iniciar Ulauncher (sin esperar a que termine)
if pgrep -x "ulauncher" > /dev/null; then
    killall ulauncher
    sleep 1
fi
nohup ulauncher --hide-window > /dev/null 2>&1 &

check_success "Configuración de Ulauncher"

print_message "green" "✓ Ulauncher instalado y configurado correctamente"
print_message "yellow" "Ulauncher se iniciará automáticamente en el próximo inicio de sesión"
print_message "yellow" "Para abrir Ulauncher, presiona Super+Espacio (Super es la tecla de Windows)"
