#!/bin/bash

# Script de configuración para Neofetch en Linux Mint

# Obtener directorio del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../lib/common.sh"

print_message "blue" "===== CONFIGURANDO NEOFETCH ====="
if ! is_installed neofetch; then
    sudo apt install -y neofetch
    check_success "Instalación de Neofetch"
fi

# Crear directorio de configuración
ensure_dir "$HOME/.config/neofetch"

# Crear configuración personalizada según el tema seleccionado
print_message "yellow" "Configurando Neofetch para el tema $THEME_NAME..."

# Configuración base para todos los temas
cat > "$HOME/.config/neofetch/config.conf" << EOF
# Configuración de Neofetch

# Ver 'man neofetch' para detalles y opciones completas
# https://github.com/dylanaraps/neofetch/wiki/Customizing-Info

print_info() {
    info title
    info underline

    info "OS" distro
    info "Host" model
    info "Kernel" kernel
    info "Uptime" uptime
    info "Packages" packages
    info "Shell" shell
    info "DE" de
    info "WM" wm
    info "Terminal" term
    info "Terminal Font" term_font
    info "CPU" cpu
    info "GPU" gpu
    info "Memory" memory

    # info "GPU Driver" gpu_driver  # Linux/macOS only
    # info "CPU Usage" cpu_usage
    # info "Disk" disk
    # info "Battery" battery
    # info "Font" font
    # info "Song" song
    # [[ "$player" ]] && prin "Music Player" "$player"
    # info "Local IP" local_ip
    # info "Public IP" public_ip
    # info "Users" users
    # info "Locale" locale  # This only works on glibc systems.

    info cols
}
EOF

# Personalizar colores según el tema
case $THEME_NAME in
    "tokyo-night")
        print_message "blue" "Aplicando colores Tokyo Night para Neofetch..."
        cat >> "$HOME/.config/neofetch/config.conf" << EOF
# Configuración de colores Tokyo Night
colors=(1 39 4 5 8 7)
bold="on"
underline_enabled="on"
underline_char="-"
separator=" ->"
block_range=(0 15)
color_blocks="on"
block_width=3
block_height=1
EOF
        ;;
    "catppuccin")
        print_message "magenta" "Aplicando colores Catppuccin para Neofetch..."
        cat >> "$HOME/.config/neofetch/config.conf" << EOF
# Configuración de colores Catppuccin
colors=(1 2 3 4 5 6)
bold="on"
underline_enabled="on"
underline_char="-"
separator=" ->"
block_range=(0 15)
color_blocks="on"
block_width=3
block_height=1
EOF
        ;;
    "nord")
        print_message "cyan" "Aplicando colores Nord para Neofetch..."
        cat >> "$HOME/.config/neofetch/config.conf" << EOF
# Configuración de colores Nord
colors=(4 12 6 13 8 7)
bold="on"
underline_enabled="on"
underline_char="-"
separator=" ->"
block_range=(0 15)
color_blocks="on"
block_width=3
block_height=1
EOF
        ;;
    "gruvbox")
        print_message "yellow" "Aplicando colores Gruvbox para Neofetch..."
        cat >> "$HOME/.config/neofetch/config.conf" << EOF
# Configuración de colores Gruvbox
colors=(11 3 10 9 8 7)
bold="on"
underline_enabled="on"
underline_char="-"
separator=" ->"
block_range=(0 15)
color_blocks="on"
block_width=3
block_height=1
EOF
        ;;
    "dracula")
        print_message "magenta" "Aplicando colores Dracula para Neofetch..."
        cat >> "$HOME/.config/neofetch/config.conf" << EOF
# Configuración de colores Dracula
colors=(5 13 4 6 2 7)
bold="on"
underline_enabled="on"
underline_char="-"
separator=" ->"
block_range=(0 15)
color_blocks="on"
block_width=3
block_height=1
EOF
        ;;
    *)
        print_message "yellow" "No se ha seleccionado un tema válido, usando colores predeterminados"
        cat >> "$HOME/.config/neofetch/config.conf" << EOF
# Configuración de colores predeterminados
colors=(4 6 1 8 8 6)
bold="on"
underline_enabled="on"
underline_char="-"
separator=":"
block_range=(0 15)
color_blocks="on"
block_width=3
block_height=1
EOF
        ;;
esac

# Completar la configuración
cat >> "$HOME/.config/neofetch/config.conf" << EOF
# Configuración general
bar_char_elapsed="-"
bar_char_total="="
bar_border="on"
bar_length=15
bar_color_elapsed="distro"
bar_color_total="distro"

# Mostrar información de la distribución Linux
ascii_distro="auto"
ascii_colors=(distro)
ascii_bold="on"

# Backend para imágenes
image_backend="ascii"
image_source="auto"

# Configuración de ascii
ascii_distro="auto"
ascii_colors=(distro)
ascii_bold="on"

# Configuración para las barras de información
bar_char_elapsed="-"
bar_char_total="="
bar_border="on"
bar_length=15
bar_color_elapsed="distro"
bar_color_total="distro"

# Opciones de información adicionales
memory_percent="on"
package_managers="on"
shell_path="off"
shell_version="on"
speed_type="bios_limit"
speed_shorthand="on"
cpu_brand="on"
cpu_speed="on"
cpu_cores="logical"
cpu_temp="off"
gpu_brand="on"
gpu_type="all"
refresh_rate="on"
gtk_shorthand="on"
gtk2="on"
gtk3="on"
public_ip_host="http://ident.me"
public_ip_timeout=2
disk_show=('/')
music_player="auto"
song_format="%artist% - %title%"
song_shorthand="off"
mpc_args=()
EOF

# Añadir Neofetch al inicio de la terminal
if grep -q "neofetch" "$HOME/.zshrc"; then
    print_message "yellow" "Neofetch ya está configurado para iniciar con la terminal"
else
    echo "" >> "$HOME/.zshrc"
    echo "# Ejecutar Neofetch al iniciar terminal" >> "$HOME/.zshrc"
    echo "neofetch" >> "$HOME/.zshrc"
    check_success "Configuración de Neofetch para iniciar con la terminal"
fi

# Ejecución de prueba
print_message "blue" "Ejemplo de salida de Neofetch:"
neofetch

check_success "Configuración de Neofetch"
