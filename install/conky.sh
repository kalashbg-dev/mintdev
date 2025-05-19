#!/bin/bash

# Script de instalación para Conky en Linux Mint

# Obtener directorio del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/security.sh"
source "$SCRIPT_DIR/../lib/idempotence.sh"

# Verificar si el componente ya está instalado
if is_component_installed "conky"; then
    print_message "yellow" "Conky ya está instalado"
    log_message "INFO" "Conky ya está instalado, omitiendo instalación"
    exit 0
fi

print_message "blue" "===== INSTALANDO Y CONFIGURANDO CONKY ====="

# Actualizar la sección de instalación para usar el sistema de registro
if ! is_installed conky-all; then
    log_message "INFO" "Iniciando instalación de Conky"
    sudo apt install -y conky-all
    check_success "Instalación de Conky"
    log_message "INFO" "Conky instalado correctamente"
fi

# Crear directorio de configuración
ensure_dir "$HOME/.config/conky"
log_message "INFO" "Directorio de configuración de Conky creado"

# Actualizar la sección de configuración para usar el sistema de temas
# Configurar Conky según el tema seleccionado
print_message "yellow" "Configurando Conky para el tema $THEME_NAME..."
log_message "INFO" "Configurando Conky con tema: $THEME_NAME"

# Usar el sistema de gestión de temas para aplicar el tema a Conky
if is_theme_compatible_with_app "$THEME_NAME" "conky"; then
    apply_theme_to_conky "$THEME_NAME"
    check_success "Aplicación del tema $THEME_NAME a Conky"
    log_message "INFO" "Tema $THEME_NAME aplicado a Conky correctamente"
else
    # Si el tema no es compatible, usar Tokyo Night como predeterminado
    print_message "yellow" "El tema $THEME_NAME no es compatible con Conky, usando Tokyo Night como predeterminado"
    log_message "WARNING" "Tema $THEME_NAME no compatible con Conky, usando Tokyo Night"
    apply_theme_to_conky "tokyo-night"
fi

# Crear script de inicio para Conky
cat > "$HOME/.config/autostart/conky.desktop" << EOF
[Desktop Entry]
Type=Application
Name=Conky
Comment=System monitor
Exec=conky --daemonize --pause=2
StartupNotify=false
Terminal=false
Categories=System;
EOF
chmod +x "$HOME/.config/autostart/conky.desktop"
log_message "INFO" "Script de inicio para Conky creado"

# Al final del script, marcar el componente como instalado
mark_component_installed "conky"
log_message "INFO" "Conky marcado como instalado en el sistema de idempotencia"

# Crear configuración predeterminada si no existe
if [ ! -f "$SCRIPT_DIR/../configs/conky/default.conf" ]; then
    ensure_dir "$SCRIPT_DIR/../configs/conky"
    cat > "$SCRIPT_DIR/../configs/conky/default.conf" << EOF
conky.config = {
    alignment = 'top_right',
    background = true,
    border_width = 1,
    cpu_avg_samples = 2,
    default_color = 'white',
    default_outline_color = 'white',
    default_shade_color = 'white',
    double_buffer = true,
    draw_borders = false,
    draw_graph_borders = true,
    draw_outline = false,
    draw_shades = false,
    extra_newline = false,
    font = 'JetBrains Mono:size=10',
    gap_x = 30,
    gap_y = 60,
    minimum_height = 5,
    minimum_width = 280,
    net_avg_samples = 2,
    no_buffers = true,
    out_to_console = false,
    out_to_ncurses = false,
    out_to_stderr = false,
    out_to_x = true,
    own_window = true,
    own_window_class = 'Conky',
    own_window_type = 'desktop',
    own_window_transparent = true,
    own_window_argb_visual = true,
    own_window_argb_value = 190,
    own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',
    show_graph_range = false,
    show_graph_scale = false,
    stippled_borders = 0,
    update_interval = 1.0,
    uppercase = false,
    use_spacer = 'none',
    use_xft = true,
};

conky.text = [[
${color white}${font JetBrains Mono:bold:size=16}${alignc}${time %H:%M:%S}${font}
${color white}${font JetBrains Mono:size=12}${alignc}${time %A %d %B %Y}${font}

${color white}${font JetBrains Mono:bold:size=12}SISTEMA ${hr 2}${font}
${color white}Hostname: ${alignr}${nodename}
${color white}Kernel: ${alignr}${kernel}
${color white}Uptime: ${alignr}${uptime}
${color white}Procesos: ${alignr}${processes}

${color white}${font JetBrains Mono:bold:size=12}CPU ${hr 2}${font}
${color white}CPU: ${alignr}${cpu}%
${color white}${cpubar}
${color white}${cpugraph 30,280}
${color white}${font JetBrains Mono:size=9}${alignc}${top name 1} ${top cpu 1}%
${color white}${alignc}${top name 2} ${top cpu 2}%
${color white}${alignc}${top name 3} ${top cpu 3}%${font}

${color white}${font JetBrains Mono:bold:size=12}MEMORIA ${hr 2}${font}
${color white}RAM: ${alignr}${mem} / ${memmax}
${color white}${membar}
${color white}${memgraph 30,280}
${color white}${font JetBrains Mono:size=9}${alignc}${top_mem name 1} ${top_mem mem 1}%
${color white}${alignc}${top_mem name 2} ${top_mem mem 2}%
${color white}${alignc}${top_mem name 3} ${top_mem mem 3}%${font}

${color white}${font JetBrains Mono:bold:size=12}DISCO ${hr 2}${font}
${color white}Root: ${alignr}${fs_used /} / ${fs_size /}
${color white}${fs_bar /}
${color white}Home: ${alignr}${fs_used /home} / ${fs_size /home}
${color white}${fs_bar /home}

${color white}${font JetBrains Mono:bold:size=12}RED ${hr 2}${font}
${if_existing /proc/net/route wlan0}
${color white}Wi-Fi (${wireless_essid wlan0}): ${alignr}${addr wlan0}
${color white}Señal: ${alignr}${wireless_link_qual_perc wlan0}%
${color white}${wireless_link_bar wlan0}
${color white}Bajada: ${alignr}${downspeed wlan0}
${color white}${downspeedgraph wlan0 30,280}
${color white}Subida: ${alignr}${upspeed wlan0}
${color white}${upspeedgraph wlan0 30,280}
${else}${if_existing /proc/net/route eth0}
${color white}Ethernet: ${alignr}${addr eth0}
${color white}Bajada: ${alignr}${downspeed eth0}
${color white}${downspeedgraph eth0 30,280}
${color white}Subida: ${alignr}${upspeed eth0}
${color white}${upspeedgraph eth0 30,280}
${endif}${endif}
]];
EOF
fi

# Crear configuración para Tokyo Night
if [ ! -f "$SCRIPT_DIR/../configs/conky/tokyo-night.conf" ]; then
    ensure_dir "$SCRIPT_DIR/../configs/conky"
    cat > "$SCRIPT_DIR/../configs/conky/tokyo-night.conf" << EOF
conky.config = {
    alignment = 'top_right',
    background = true,
    border_width = 1,
    cpu_avg_samples = 2,
    default_color = '#a9b1d6',
    default_outline_color = '#a9b1d6',
    default_shade_color = '#a9b1d6',
    double_buffer = true,
    draw_borders = false,
    draw_graph_borders = true,
    draw_outline = false,
    draw_shades = false,
    extra_newline = false,
    font = 'JetBrains Mono:size=10',
    gap_x = 30,
    gap_y = 60,
    minimum_height = 5,
    minimum_width = 280,
    net_avg_samples = 2,
    no_buffers = true,
    out_to_console = false,
    out_to_ncurses = false,
    out_to_stderr = false,
    out_to_x = true,
    own_window = true,
    own_window_class = 'Conky',
    own_window_type = 'desktop',
    own_window_transparent = false,
    own_window_argb_visual = true,
    own_window_argb_value = 190,
    own_window_colour = '#1a1b26',
    own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',
    show_graph_range = false,
    show_graph_scale = false,
    stippled_borders = 0,
    update_interval = 1.0,
    uppercase = false,
    use_spacer = 'none',
    use_xft = true,
};

conky.text = [[
${color #7aa2f7}${font JetBrains Mono:bold:size=16}${alignc}${time %H:%M:%S}${font}
${color #7aa2f7}${font JetBrains Mono:size=12}${alignc}${time %A %d %B %Y}${font}

${color #7aa2f7}${font JetBrains Mono:bold:size=12}SISTEMA ${hr 2}${font}
${color #a9b1d6}Hostname: ${alignr}${nodename}
${color #a9b1d6}Kernel: ${alignr}${kernel}
${color #a9b1d6}Uptime: ${alignr}${uptime}
${color #a9b1d6}Procesos: ${alignr}${processes}

${color #7aa2f7}${font JetBrains Mono:bold:size=12}CPU ${hr 2}${font}
${color #a9b1d6}CPU: ${alignr}${cpu}%
${color #a9b1d6}${cpubar 4,280 #7aa2f7 #1a1b26}
${color #a9b1d6}${cpugraph 30,280 #7aa2f7 #ad8ee6}
${color #a9b1d6}${font JetBrains Mono:size=9}${alignc}${top name 1} ${top cpu 1}%
${color #a9b1d6}${alignc}${top name 2} ${top cpu 2}%
${color #a9b1d6}${alignc}${top name 3} ${top cpu 3}%${font}

${color #7aa2f7}${font JetBrains Mono:bold:size=12}MEMORIA ${hr 2}${font}
${color #a9b1d6}RAM: ${alignr}${mem} / ${memmax}
${color #a9b1d6}${membar 4,280 #7aa2f7 #1a1b26}
${color #a9b1d6}${memgraph 30,280 #7aa2f7 #ad8ee6}
${color #a9b1d6}${font JetBrains Mono:size=9}${alignc}${top_mem name 1} ${top_mem mem 1}%
${color #a9b1d6}${alignc}${top_mem name 2} ${top_mem mem 2}%
${color #a9b1d6}${alignc}${top_mem name 3} ${top_mem mem 3}%${font}

${color #7aa2f7}${font JetBrains Mono:bold:size=12}DISCO ${hr 2}${font}
${color #a9b1d6}Root: ${alignr}${fs_used /} / ${fs_size /}
${color #a9b1d6}${fs_bar 4,280 #7aa2f7 #1a1b26 /}
${color #a9b1d6}Home: ${alignr}${fs_used /home} / ${fs_size /home}
${color #a9b1d6}${fs_bar 4,280 #7aa2f7 #1a1b26 /home}

${color #7aa2f7}${font JetBrains Mono:bold:size=12}RED ${hr 2}${font}
${if_existing /proc/net/route wlan0}
${color #a9b1d6}Wi-Fi (${wireless_essid wlan0}): ${alignr}${addr wlan0}
${color #a9b1d6}Señal: ${alignr}${wireless_link_qual_perc wlan0}%
${color #a9b1d6}${wireless_link_bar 4,280 #7aa2f7 #1a1b26 wlan0}
${color #a9b1d6}Bajada: ${alignr}${downspeed wlan0}
${color #a9b1d6}${downspeedgraph wlan0 30,280 #7aa2f7 #ad8ee6}
${color #a9b1d6}Subida: ${alignr}${upspeed wlan0}
${color #a9b1d6}${upspeedgraph wlan0 30,280 #7aa2f7 #ad8ee6}
${else}${if_existing /proc/net/route eth0}
${color #a9b1d6}Ethernet: ${alignr}${addr eth0}
${color #a9b1d6}Bajada: ${alignr}${downspeed eth0}
${color #a9b1d6}${downspeedgraph eth0 30,280 #7aa2f7 #ad8ee6}
${color #a9b1d6}Subida: ${alignr}${upspeed eth0}
${color #a9b1d6}${upspeedgraph eth0 30,280 #7aa2f7 #ad8ee6}
${endif}${endif}
]];
EOF
fi

check_success "Configuración de Conky"

print_message "green" "✓ Conky instalado y configurado correctamente"
print_message "yellow" "Conky se iniciará automáticamente en el próximo inicio de sesión"
print_message "yellow" "Para iniciarlo manualmente, ejecuta: conky --daemonize"
