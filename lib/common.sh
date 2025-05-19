#!/bin/bash

# Archivo de funciones comunes para todos los scripts

# Colores para mensajes
GREEN="\e[32m"
BLUE="\e[34m"
YELLOW="\e[33m"
RED="\e[31m"
MAGENTA="\e[35m"
CYAN="\e[36m"
RESET="\e[0m"

# Función para imprimir mensajes coloreados
print_message() {
    local color=$1
    local message=$2
    
    case $color in
        "green") echo -e "${GREEN}$message${RESET}" ;;
        "blue") echo -e "${BLUE}$message${RESET}" ;;
        "yellow") echo -e "${YELLOW}$message${RESET}" ;;
        "red") echo -e "${RED}$message${RESET}" ;;
        "magenta") echo -e "${MAGENTA}$message${RESET}" ;;
        "cyan") echo -e "${CYAN}$message${RESET}" ;;
        *) echo "$message" ;;
    esac
}

# Función para verificar si un comando se ejecutó correctamente
check_success() {
    if [ $? -eq 0 ]; then
        print_message "green" "✓ Éxito: $1"
        log_message "INFO" "Operación exitosa: $1"
    else
        print_message "red" "✗ Error: $1"
        log_message "ERROR" "Operación fallida: $1"
        read -p "¿Deseas continuar a pesar de este error? (s/n): " continue_anyway
        if [[ "$continue_anyway" != [Ss]* ]]; then
            print_message "red" "Abortando instalación."
            log_message "ERROR" "Instalación abortada por el usuario después de error"
            exit 1
        else
            print_message "yellow" "⚠️ Continuando a pesar del error..."
            log_message "WARNING" "Usuario eligió continuar a pesar del error"
        fi
    fi
}

# Función para verificar si un paquete está instalado
is_installed() {
    if dpkg -l "$1" &> /dev/null; then
        return 0
    elif command -v "$1" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Función para crear un directorio si no existe
ensure_dir() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        log_message "INFO" "Directorio creado: $1"
        print_message "yellow" "Directorio creado: $1"
    fi
}

# Función para hacer copia de seguridad de un archivo
backup_file() {
    if [ -f "$1" ]; then
        local backup_file="$1.backup.$(date +%Y%m%d%H%M%S)"
        cp "$1" "$backup_file"
        log_message "INFO" "Copia de seguridad creada: $backup_file"
        print_message "yellow" "Copia de seguridad creada: $backup_file"
    fi
}

# Función para descargar un archivo (forzando HTTPS)
download_file() {
    local url=$1
    local output_file=$2
    local force=${3:-false}
    
    # Verificar si la URL usa HTTPS
    if [[ "$url" != https://* ]]; then
        log_message "ERROR" "URL insegura detectada: $url"
        print_message "red" "Error: Solo se permiten URLs HTTPS por seguridad."
        print_message "red" "URL proporcionada: $url"
        return 1
    fi
    
    # Usar la función de descarga segura
    secure_download "$url" "$output_file" "$force"
    return $?
}

# Función para obtener la versión actual del sistema
get_system_version() {
    if [ -f /etc/linuxmint/info ]; then
        grep 'RELEASE=' /etc/linuxmint/info | cut -d= -f2 | tr -d '"'
    elif [ -f /etc/lsb-release ]; then
        grep 'DISTRIB_RELEASE=' /etc/lsb-release | cut -d= -f2
    else
        echo "unknown"
    fi
}

# Función para verificar compatibilidad del sistema
check_system_compatibility() {
    local min_version=${1:-"20.0"}
    local current_version=$(get_system_version)
    
    if [[ "$current_version" == "unknown" ]]; then
        log_message "WARNING" "No se pudo determinar la versión del sistema"
        print_message "yellow" "⚠️ No se pudo determinar la versión del sistema"
        return 1
    fi
    
    if (( $(echo "$current_version < $min_version" | bc -l) )); then
        log_message "WARNING" "Versión del sistema ($current_version) es menor que la mínima recomendada ($min_version)"
        print_message "yellow" "⚠️ Versión del sistema ($current_version) es menor que la mínima recomendada ($min_version)"
        return 1
    fi
    
    return 0
}

# Función para verificar espacio en disco
check_disk_space() {
    local min_space=${1:-5}  # Espacio mínimo en GB
    local mount_point=${2:-"/"}
    
    local free_space=$(df -BG "$mount_point" | awk 'NR==2 {print $4}' | sed 's/G//')
    
    if (( $(echo "$free_space < $min_space" | bc -l) )); then
        log_message "WARNING" "Espacio libre insuficiente: $free_space GB (mínimo recomendado: $min_space GB)"
        print_message "yellow" "⚠️ Espacio libre insuficiente: $free_space GB (mínimo recomendado: $min_space GB)"
        return 1
    fi
    
    return 0
}

# Función para verificar memoria disponible
check_memory() {
    local min_memory=${1:-2}  # Memoria mínima en GB
    
    local total_memory=$(free -g | awk 'NR==2 {print $2}')
    
    if (( total_memory < min_memory )); then
        log_message "WARNING" "Memoria insuficiente: $total_memory GB (mínimo recomendado: $min_memory GB)"
        print_message "yellow" "⚠️ Memoria insuficiente: $total_memory GB (mínimo recomendado: $min_memory GB)"
        return 1
    fi
    
    return 0
}

# Función para verificar conexión a Internet
check_internet_connection() {
    if ping -c 1 8.8.8.8 &> /dev/null; then
        return 0
    else
        log_message "ERROR" "No hay conexión a Internet"
        print_message "red" "Error: No hay conexión a Internet"
        return 1
    fi
}

# Función para verificar si el usuario tiene permisos sudo
check_sudo_permissions() {
    if sudo -n true 2>/dev/null; then
        return 0
    else
        log_message "WARNING" "El usuario no tiene permisos sudo o requiere contraseña"
        print_message "yellow" "⚠️ Se te pedirá tu contraseña para operaciones que requieran privilegios de administrador"
        return 1
    fi
}

# Función para instalar un paquete si no está instalado
install_package_if_needed() {
    local package=$1
    
    if ! is_installed "$package"; then
        print_message "yellow" "Instalando $package..."
        log_message "INFO" "Instalando paquete: $package"
        sudo apt install -y "$package"
        if [ $? -eq 0 ]; then
            print_message "green" "✓ $package instalado correctamente"
            log_message "INFO" "Paquete instalado correctamente: $package"
            return 0
        else
            print_message "red" "✗ Error al instalar $package"
            log_message "ERROR" "Error al instalar paquete: $package"
            return 1
        fi
    else
        print_message "yellow" "$package ya está instalado"
        log_message "INFO" "Paquete ya instalado: $package"
        return 0
    fi
}
