#!/bin/bash

# Script de instalación para Alacritty en Linux Mint

# Obtener directorio del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/security.sh"
source "$SCRIPT_DIR/../lib/idempotence.sh"

# Verificar si el componente ya está instalado
if is_component_installed "alacritty"; then
    print_message "yellow" "Alacritty ya está instalado"
    log_message "INFO" "Alacritty ya está instalado, omitiendo instalación"
    exit 0
fi

print_message "blue" "===== INSTALANDO Y CONFIGURANDO ALACRITTY ====="
if ! is_installed alacritty; then
    # Instalar dependencias
    sudo apt install -y cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3
    check_success "Instalación de dependencias para Alacritty"
    log_message "INFO" "Dependencias para Alacritty instaladas correctamente"

    # Verificar si Rust está instalado
    if ! command -v cargo &> /dev/null; then
        print_message "yellow" "Rust no está instalado. Instalando Rust..."
        log_message "INFO" "Instalando Rust para compilar Alacritty"
        
        # Usar secure_download para descargar el script de instalación de Rust
        secure_download "https://sh.rustup.rs" "/tmp/mint-dev-setup/rustup.sh"
        chmod +x /tmp/mint-dev-setup/rustup.sh
        /tmp/mint-dev-setup/rustup.sh -y
        source "$HOME/.cargo/env"
        check_success "Instalación de Rust"
        log_message "INFO" "Rust instalado correctamente"
    fi

    # Clonar el repositorio de Alacritty usando secure_download
    print_message "yellow" "Clonando el repositorio de Alacritty..."
    log_message "INFO" "Clonando repositorio de Alacritty"
    ensure_dir "/tmp/mint-dev-setup"
    
    # Usar git clone con HTTPS en lugar de HTTP
    git clone https://github.com/alacritty/alacritty.git /tmp/mint-dev-setup/alacritty
    cd /tmp/mint-dev-setup/alacritty
    
    # Compilar e instalar Alacritty
    print_message "yellow" "Compilando Alacritty (esto puede tardar unos minutos)..."
    log_message "INFO" "Compilando Alacritty"
    cargo build --release
    sudo cp target/release/alacritty /usr/local/bin/
    check_success "Compilación e instalación de Alacritty"
    log_message "INFO" "Alacritty compilado e instalado correctamente"

    # Instalar archivos de escritorio y completación
    print_message "yellow" "Instalando archivos de escritorio y completación..."
    sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
    sudo desktop-file-install extra/linux/Alacritty.desktop
    sudo update-desktop-database

    # Instalar completación para zsh
    mkdir -p "${ZDOTDIR:-~}/.zsh_functions"
    cp extra/completions/_alacritty "${ZDOTDIR:-~}/.zsh_functions/_alacritty"

    # Instalar página de manual
    sudo mkdir -p /usr/local/share/man/man1
    gzip -c extra/alacritty.man | sudo tee /usr/local/share/man/man1/alacritty.1.gz > /dev/null
    gzip -c extra/alacritty-msg.man | sudo tee /usr/local/share/man/man1/alacritty-msg.1.gz > /dev/null

    check_success "Instalación de Alacritty"
else
    print_message "yellow" "Alacritty ya está instalado"
fi

# Crear directorio de configuración
ensure_dir "$HOME/.config/alacritty"

# Configurar Alacritty según el tema seleccionado
print_message "yellow" "Configurando Alacritty para el tema $THEME_NAME..."
log_message "INFO" "Configurando Alacritty con tema: $THEME_NAME"

# Usar el sistema de gestión de temas para aplicar el tema a Alacritty
if is_theme_compatible_with_app "$THEME_NAME" "alacritty"; then
    apply_theme_to_alacritty "$THEME_NAME"
    check_success "Aplicación del tema $THEME_NAME a Alacritty"
    log_message "INFO" "Tema $THEME_NAME aplicado a Alacritty correctamente"
else
    # Si el tema no es compatible, usar Tokyo Night como predeterminado
    print_message "yellow" "El tema $THEME_NAME no es compatible con Alacritty, usando Tokyo Night como predeterminado"
    log_message "WARNING" "Tema $THEME_NAME no compatible con Alacritty, usando Tokyo Night"
    apply_theme_to_alacritty "tokyo-night"
fi

print_message "green" "✓ Alacritty instalado y configurado correctamente"
print_message "yellow" "Puedes iniciar Alacritty desde el menú de aplicaciones o ejecutando 'alacritty'"

# Al final del script, marcar el componente como instalado
mark_component_installed "alacritty"
log_message "INFO" "Alacritty marcado como instalado en el sistema de idempotencia"
