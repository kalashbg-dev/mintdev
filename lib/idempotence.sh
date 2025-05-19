#!/bin/bash

# Funciones para mejorar la idempotencia de los scripts
# Permite detectar componentes ya instalados y evitar reinstalaciones

# Archivo de estado para seguimiento de componentes instalados
STATE_FILE="$HOME/.mintdev_state.json"

# Función para inicializar el archivo de estado si no existe
init_state_file() {
    if [ ! -f "$STATE_FILE" ]; then
        log_message "INFO" "Creando archivo de estado: $STATE_FILE"
        echo '{
  "installed_components": {},
  "theme": "default",
  "installation_date": "",
  "last_update": "",
  "version": "1.0.0"
}' > "$STATE_FILE"
    fi
}

# Función para leer el archivo de estado
read_state_file() {
    if [ ! -f "$STATE_FILE" ]; then
        init_state_file
    fi
    cat "$STATE_FILE"
}

# Función para actualizar el archivo de estado
update_state_file() {
    local new_state=$1
    echo "$new_state" > "$STATE_FILE"
    log_message "INFO" "Archivo de estado actualizado"
}

# Función para marcar un componente como instalado
mark_component_installed() {
    local component=$1
    local version=${2:-"latest"}
    local date=$(date +"%Y-%m-%d %H:%M:%S")
    
    log_message "INFO" "Marcando componente como instalado: $component (versión: $version)"
    
    local state=$(read_state_file)
    local new_state=$(echo "$state" | jq --arg comp "$component" --arg ver "$version" --arg date "$date" \
        '.installed_components[$comp] = {"version": $ver, "installation_date": $date, "status": "installed"}')
    
    update_state_file "$new_state"
}

# Función para marcar un componente como desinstalado
mark_component_uninstalled() {
    local component=$1
    local date=$(date +"%Y-%m-%d %H:%M:%S")
    
    log_message "INFO" "Marcando componente como desinstalado: $component"
    
    local state=$(read_state_file)
    local new_state=$(echo "$state" | jq --arg comp "$component" --arg date "$date" \
        '.installed_components[$comp] = {"status": "uninstalled", "uninstallation_date": $date}')
    
    update_state_file "$new_state"
}

# Función para verificar si un componente está instalado según el archivo de estado
is_component_installed_in_state() {
    local component=$1
    
    if [ ! -f "$STATE_FILE" ]; then
        return 1
    fi
    
    local status=$(jq -r --arg comp "$component" '.installed_components[$comp].status // "unknown"' "$STATE_FILE")
    
    if [ "$status" = "installed" ]; then
        return 0
    else
        return 1
    fi
}

# Función para detectar si un componente está realmente instalado en el sistema
detect_component_installation() {
    local component=$1
    
    case $component in
        "vscode")
            is_installed code && return 0 || return 1
            ;;
        "docker")
            is_installed docker && return 0 || return 1
            ;;
        "nodejs")
            is_installed node && return 0 || return 1
            ;;
        "python")
            is_installed python3 && return 0 || return 1
            ;;
        "zsh")
            is_installed zsh && return 0 || return 1
            ;;
        "oh-my-zsh")
            [ -d "$HOME/.oh-my-zsh" ] && return 0 || return 1
            ;;
        "tmux")
            is_installed tmux && return 0 || return 1
            ;;
        "alacritty")
            is_installed alacritty && return 0 || return 1
            ;;
        "bat")
            (is_installed bat || is_installed batcat) && return 0 || return 1
            ;;
        "micro")
            is_installed micro && return 0 || return 1
            ;;
        "ranger")
            is_installed ranger && return 0 || return 1
            ;;
        "starship")
            is_installed starship && return 0 || return 1
            ;;
        "mongodb")
            is_installed mongod && return 0 || return 1
            ;;
        "postgresql")
            is_installed psql && return 0 || return 1
            ;;
        "spotify")
            is_installed spotify && return 0 || return 1
            ;;
        "github-cli")
            is_installed gh && return 0 || return 1
            ;;
        "conky")
            is_installed conky && return 0 || return 1
            ;;
        "plank")
            is_installed plank && return 0 || return 1
            ;;
        "ulauncher")
            is_installed ulauncher && return 0 || return 1
            ;;
        "variety")
            is_installed variety && return 0 || return 1
            ;;
        "libreoffice")
            is_installed libreoffice && return 0 || return 1
            ;;
        "postman")
            [ -d "/opt/Postman" ] && return 0 || return 1
            ;;
        "jupyter")
            is_installed jupyter && return 0 || return 1
            ;;
        *)
            log_message "WARNING" "Componente desconocido para detección: $component"
            return 1
            ;;
    esac
}

# Función para sincronizar el estado con la realidad del sistema
sync_component_state() {
    local component=$1
    
    # Detectar si el componente está realmente instalado
    if detect_component_installation "$component"; then
        # Si está instalado pero no en el estado, actualizarlo
        if ! is_component_installed_in_state "$component"; then
            log_message "INFO" "Sincronizando estado: $component está instalado pero no registrado"
            mark_component_installed "$component" "detected"
        fi
    else
        # Si no está instalado pero sí en el estado, actualizarlo
        if is_component_installed_in_state "$component"; then
            log_message "INFO" "Sincronizando estado: $component no está instalado pero está registrado"
            mark_component_uninstalled "$component"
        fi
    fi
}

# Función para verificar si un componente está instalado (combinando estado y detección)
is_component_installed() {
    local component=$1
    local force_check=${2:-false}
    
    # Si se fuerza la comprobación o no hay archivo de estado, detectar directamente
    if [ "$force_check" = "true" ] || [ ! -f "$STATE_FILE" ]; then
        detect_component_installation "$component"
        return $?
    fi
    
    # Primero verificar en el archivo de estado
    if is_component_installed_in_state "$component"; then
        return 0
    fi
    
    # Si no está en el estado, intentar detectarlo
    if detect_component_installation "$component"; then
        # Actualizar el estado
        mark_component_installed "$component" "detected"
        return 0
    fi
    
    return 1
}

# Función para establecer el tema actual
set_current_theme() {
    local theme=$1
    
    log_message "INFO" "Estableciendo tema actual: $theme"
    
    local state=$(read_state_file)
    local new_state=$(echo "$state" | jq --arg theme "$theme" '.theme = $theme')
    
    update_state_file "$new_state"
}

# Función para obtener el tema actual
get_current_theme() {
    if [ ! -f "$STATE_FILE" ]; then
        echo "default"
        return
    fi
    
    jq -r '.theme // "default"' "$STATE_FILE"
}

# Función para actualizar la fecha de última actualización
update_last_update() {
    local date=$(date +"%Y-%m-%d %H:%M:%S")
    
    log_message "INFO" "Actualizando fecha de última actualización: $date"
    
    local state=$(read_state_file)
    local new_state=$(echo "$state" | jq --arg date "$date" '.last_update = $date')
    
    update_state_file "$new_state"
}

# Función para establecer la fecha de instalación inicial
set_installation_date() {
    local date=$(date +"%Y-%m-%d %H:%M:%S")
    
    log_message "INFO" "Estableciendo fecha de instalación: $date"
    
    local state=$(read_state_file)
    
    # Solo establecer si no existe
    if [ "$(echo "$state" | jq -r '.installation_date')" = "" ]; then
        local new_state=$(echo "$state" | jq --arg date "$date" '.installation_date = $date')
        update_state_file "$new_state"
    fi
}

# Inicializar el archivo de estado
init_state_file
