#!/bin/bash

# Script de instalación para Tmux en Linux Mint

# Obtener directorio del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/security.sh"
source "$SCRIPT_DIR/../lib/idempotence.sh"

# Verificar si el componente ya está instalado
if is_component_installed "tmux"; then
    print_message "yellow" "Tmux ya está instalado"
    log_message "INFO" "Tmux ya está instalado, omitiendo instalación"
    exit 0
fi

print_message "blue" "===== INSTALANDO Y CONFIGURANDO TMUX ====="
if ! is_installed tmux; then
    log_message "INFO" "Iniciando instalación de Tmux"
    sudo apt install -y tmux
    check_success "Instalación de Tmux"
    log_message "INFO" "Tmux instalado correctamente"
else
    print_message "yellow" "Tmux ya está instalado"
    log_message "INFO" "Tmux ya está instalado, omitiendo instalación"
fi

# Comprobar si TPM (Tmux Plugin Manager) está instalado
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    print_message "yellow" "Instalando Tmux Plugin Manager (TPM)..."
    log_message "INFO" "Instalando Tmux Plugin Manager"
    
    # Usar git clone con HTTPS en lugar de HTTP
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    check_success "Instalación de Tmux Plugin Manager"
    log_message "INFO" "Tmux Plugin Manager instalado correctamente"
fi

# Configurar Tmux según el tema seleccionado
print_message "yellow" "Configurando Tmux para el tema $THEME_NAME..."
log_message "INFO" "Configurando Tmux con tema: $THEME_NAME"

# Usar el sistema de gestión de temas para aplicar el tema a Tmux
if is_theme_compatible_with_app "$THEME_NAME" "tmux"; then
    apply_theme_to_tmux "$THEME_NAME"
    check_success "Aplicación del tema $THEME_NAME a Tmux"
    log_message "INFO" "Tema $THEME_NAME aplicado a Tmux correctamente"
else
    # Si el tema no es compatible, usar Tokyo Night como predeterminado
    print_message "yellow" "El tema $THEME_NAME no es compatible con Tmux, usando Tokyo Night como predeterminado"
    log_message "WARNING" "Tema $THEME_NAME no compatible con Tmux, usando Tokyo Night"
    apply_theme_to_tmux "tokyo-night"
fi

# Configurar plugins
cat >> "$HOME/.tmux.conf" << EOF

# Lista de plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'tmux-plugins/tmux-yank'

# Configuración de plugins
set -g @continuum-restore 'on'
set -g @resurrect-capture-pane-contents 'on'

# Inicializar TMUX plugin manager (debe estar al final del archivo)
run '~/.tmux/plugins/tpm/tpm'
EOF

# Instalar plugins
print_message "yellow" "Instalando plugins de Tmux..."
log_message "INFO" "Instalando plugins de Tmux"
~/.tmux/plugins/tpm/scripts/install_plugins.sh > /dev/null 2>&1
check_success "Instalación de plugins"
log_message "INFO" "Plugins de Tmux instalados correctamente"

print_message "green" "✓ Tmux instalado y configurado correctamente"
print_message "yellow" "Para iniciar Tmux, ejecuta 'tmux' en tu terminal"
print_message "yellow" "Atajos importantes:"
print_message "yellow" "  Ctrl+a c  - Crear nueva ventana"
print_message "yellow" "  Ctrl+a ,  - Renombrar ventana"
print_message "yellow" "  Ctrl+a n  - Ir a la siguiente ventana"
print_message "yellow" "  Ctrl+a p  - Ir a la ventana anterior"
print_message "yellow" "  Ctrl+a |  - Dividir panel horizontalmente"
print_message "yellow" "  Ctrl+a -  - Dividir panel verticalmente"
print_message "yellow" "  Ctrl+a r  - Recargar configuración"
print_message "yellow" "  Ctrl+a d  - Desacoplar sesión (puede volver con 'tmux attach')"

# Al final del script, marcar el componente como instalado
mark_component_installed "tmux"
log_message "INFO" "Tmux marcado como instalado en el sistema de idempotencia"
