#!/bin/bash

# Script de instalación para Plank Dock en Linux Mint

# Obtener directorio del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../lib/common.sh"

print_message "blue" "===== INSTALANDO Y CONFIGURANDO PLANK DOCK ====="
if ! is_installed plank; then
    sudo apt install -y plank
    check_success "Instalación de Plank Dock"
fi

# Crear directorio de configuración
ensure_dir "$HOME/.config/plank/dock1/launchers"

# Configurar Plank según el tema seleccionado
print_message "yellow" "Configurando Plank para el tema $THEME_NAME..."

# Configuración predeterminada de Plank
mkdir -p "$HOME/.config/plank/dock1"
cat > "$HOME/.config/plank/dock1/settings" << EOF
[PlankDockPreferences]
#Whether to show only windows of the current workspace.
CurrentWorkspaceOnly=false
#The size of dock icons (in pixels).
IconSize=48
#If 0, the dock won't hide. If 1, the dock intelligently hides. If 2, the dock auto-hides. If 3, the dock dodges active maximized windows. If 4, the dock dodges every window.
HideMode=1
#Time (in ms) to wait before unhiding the dock.
UnhideDelay=0
#Time (in ms) to wait before hiding the dock.
HideDelay=0
#The monitor number for the dock. Use -1 to keep on the primary monitor.
Monitor=-1
#List of *.dockitem files on this dock. DO NOT MODIFY
DockItems=
#The position for the dock on the monitor. If 0, left. If 1, right. If 2, top. If 3, bottom.
Position=3
#The dock's position offset from center (in percent).
Offset=0
#The name of the dock's theme folder.
Theme=Transparent
#The alignment for the dock on the monitor's edge. If 0, panel-mode. If 1, left-aligned. If 2, right-aligned. If 3, centered.
Alignment=3
#The alignment of the items in this dock. If 0, centered. If 1, left-aligned. If 2, right-aligned.
ItemsAlignment=0
#Whether to prevent drag'n'drop actions and lock items on the dock.
LockItems=false
#Whether to use pressure-based revealing of the dock if the support is available.
PressureReveal=false
#Whether to show only pinned applications. Useful for running more then one dock.
PinnedOnly=false
#Whether to automatically pin an application if it seems useful to do.
AutoPinning=true
#Whether to show the item for the dock itself.
ShowDockItem=false
#Whether the dock will zoom when hovered.
ZoomEnabled=true
#The dock's icon-zoom (in percent).
ZoomPercent=150
EOF

# Crear lanzadores predeterminados para Plank
LAUNCHERS=(
    "nemo.dockitem"
    "firefox.dockitem"
    "gnome-terminal.dockitem"
    "code.dockitem"
)

# Crea los lanzadores individuales
cat > "$HOME/.config/plank/dock1/launchers/nemo.dockitem" << EOF
[PlankDockItemPreferences]
Launcher=file:///usr/share/applications/nemo.desktop
EOF

cat > "$HOME/.config/plank/dock1/launchers/firefox.dockitem" << EOF
[PlankDockItemPreferences]
Launcher=file:///usr/share/applications/firefox.desktop
EOF

cat > "$HOME/.config/plank/dock1/launchers/gnome-terminal.dockitem" << EOF
[PlankDockItemPreferences]
Launcher=file:///usr/share/applications/gnome-terminal.desktop
EOF

cat > "$HOME/.config/plank/dock1/launchers/code.dockitem" << EOF
[PlankDockItemPreferences]
Launcher=file:///usr/share/applications/code.desktop
EOF

# Configurar el tema según la selección
case $THEME_NAME in
    "tokyo-night")
        print_message "blue" "Aplicando tema Tokyo Night para Plank..."
        # El tema Transparent funciona bien con Tokyo Night
        ;;
    "catppuccin")
        print_message "magenta" "Aplicando tema Catppuccin para Plank..."
        # Obtener tema de Catppuccin para Plank si existe
        if [ ! -d "$HOME/.local/share/plank/themes/Catppuccin" ]; then
            ensure_dir "$HOME/.local/share/plank/themes"
            git clone https://github.com/catppuccin/plank.git /tmp/mint-dev-setup/catppuccin-plank
            cp -r /tmp/mint-dev-setup/catppuccin-plank/themes/* "$HOME/.local/share/plank/themes/"
            sed -i 's/Theme=Transparent/Theme=Catppuccin-Mocha/g' "$HOME/.config/plank/dock1/settings"
            check_success "Configuración del tema Catppuccin para Plank"
        fi
        ;;
    "nord")
        print_message "cyan" "Aplicando tema Nord para Plank..."
        # El tema Transparent funciona bien con Nord
        ;;
    "gruvbox")
        print_message "yellow" "Aplicando tema Gruvbox para Plank..."
        # El tema Transparent funciona bien con Gruvbox
        ;;
    "dracula")
        print_message "magenta" "Aplicando tema Dracula para Plank..."
        # Obtener tema de Dracula para Plank si existe
        if [ ! -d "$HOME/.local/share/plank/themes/Dracula" ]; then
            ensure_dir "$HOME/.local/share/plank/themes"
            git clone https://github.com/dracula/plank.git /tmp/mint-dev-setup/dracula-plank
            cp -r /tmp/mint-dev-setup/dracula-plank/Dracula "$HOME/.local/share/plank/themes/"
            sed -i 's/Theme=Transparent/Theme=Dracula/g' "$HOME/.config/plank/dock1/settings"
            check_success "Configuración del tema Dracula para Plank"
        fi
        ;;
    *)
        print_message "yellow" "No se ha seleccionado un tema válido, usando tema Transparent predeterminado"
        ;;
esac

# Actualizar la lista de ítems en el dock
DOCK_ITEMS=""
for item in "${LAUNCHERS[@]}"; do
    if [ -z "$DOCK_ITEMS" ]; then
        DOCK_ITEMS="$item"
    else
        DOCK_ITEMS="$DOCK_ITEMS;$item"
    fi
done

# Actualizar la configuración con los elementos del dock
sed -i "s/DockItems=/DockItems=$DOCK_ITEMS/g" "$HOME/.config/plank/dock1/settings"

# Crear script de inicio para Plank
cat > "$HOME/.config/autostart/plank.desktop" << EOF
[Desktop Entry]
Type=Application
Name=Plank
Comment=Dock para Linux Mint
Exec=plank
StartupNotify=false
Terminal=false
Categories=Utility;
EOF
chmod +x "$HOME/.config/autostart/plank.desktop"

# Iniciar Plank (sin esperar a que termine)
if pgrep -x "plank" > /dev/null; then
    killall plank
    sleep 1
fi
nohup plank > /dev/null 2>&1 &

check_success "Configuración de Plank Dock"

print_message "green" "✓ Plank Dock instalado y configurado correctamente"
print_message "yellow" "Plank se iniciará automáticamente en el próximo inicio de sesión"
