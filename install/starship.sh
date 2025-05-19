#!/bin/bash

# Script de instalación para Starship prompt en Linux Mint

# Obtener directorio del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/security.sh"
source "$SCRIPT_DIR/../lib/idempotence.sh"

# Verificar si el componente ya está instalado
if is_component_installed "starship"; then
    print_message "yellow" "Starship ya está instalado"
    log_message "INFO" "Starship ya está instalado, omitiendo instalación"
    exit 0
fi

print_message "blue" "===== INSTALANDO Y CONFIGURANDO STARSHIP PROMPT ====="

# Actualizar la sección de instalación para usar secure_download
# Reemplazar la sección donde se instala Starship con:
if ! command -v starship &> /dev/null; then
    print_message "yellow" "Instalando Starship..."
    log_message "INFO" "Iniciando instalación de Starship"
    
    # Usar secure_download para descargar el script de instalación
    secure_download "https://starship.rs/install.sh" "/tmp/mint-dev-setup/starship-install.sh"
    chmod +x /tmp/mint-dev-setup/starship-install.sh
    /tmp/mint-dev-setup/starship-install.sh --yes
    check_success "Instalación de Starship"
    log_message "INFO" "Starship instalado correctamente"
else
    print_message "yellow" "Starship ya está instalado"
    log_message "INFO" "Starship ya está instalado, omitiendo instalación"
fi

# Actualizar la sección de configuración para usar el sistema de temas
# Reemplazar la sección donde se configura Starship con:
# Configurar Starship según el tema seleccionado
print_message "yellow" "Configurando Starship para el tema $THEME_NAME..."
log_message "INFO" "Configurando Starship con tema: $THEME_NAME"

# Usar el sistema de gestión de temas para aplicar el tema a Starship
if is_theme_compatible_with_app "$THEME_NAME" "starship"; then
    apply_theme_to_starship "$THEME_NAME"
    check_success "Aplicación del tema $THEME_NAME a Starship"
    log_message "INFO" "Tema $THEME_NAME aplicado a Starship correctamente"
else
    # Si el tema no es compatible, usar Tokyo Night como predeterminado
    print_message "yellow" "El tema $THEME_NAME no es compatible con Starship, usando Tokyo Night como predeterminado"
    log_message "WARNING" "Tema $THEME_NAME no compatible con Starship, usando Tokyo Night"
    apply_theme_to_starship "tokyo-night"
fi

# Configurar la inicialización de Starship en los archivos de shell
print_message "yellow" "Configurando Starship en los archivos de shell..."

# Para Zsh
if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q "starship init zsh" "$HOME/.zshrc"; then
        echo "" >> "$HOME/.zshrc"
        echo "# Inicializar Starship prompt" >> "$HOME/.zshrc"
        echo 'eval "$(starship init zsh)"' >> "$HOME/.zshrc"
        print_message "green" "✓ Starship configurado para Zsh"
    else
        print_message "yellow" "Starship ya está configurado en Zsh"
    fi
fi

# Para Bash
if [ -f "$HOME/.bashrc" ]; then
    if ! grep -q "starship init bash" "$HOME/.bashrc"; then
        echo "" >> "$HOME/.bashrc"
        echo "# Inicializar Starship prompt" >> "$HOME/.bashrc"
        echo 'eval "$(starship init bash)"' >> "$HOME/.bashrc"
        print_message "green" "✓ Starship configurado para Bash"
    else
        print_message "yellow" "Starship ya está configurado en Bash"
    fi
fi

print_message "green" "✓ Starship instalado y configurado correctamente"
print_message "yellow" "Abre una nueva terminal o ejecuta 'source ~/.zshrc' o 'source ~/.bashrc' para ver los cambios"

# Al final del script, marcar el componente como instalado
mark_component_installed "starship"
log_message "INFO" "Starship marcado como instalado en el sistema de idempotencia"
