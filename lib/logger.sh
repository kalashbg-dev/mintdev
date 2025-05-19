#!/bin/bash

# Sistema de registro avanzado para MintDev Setup
# Proporciona funciones para registrar mensajes con diferentes niveles de severidad

# Configuración del sistema de registro
LOG_DIR="$HOME/.mintdev/logs"
LOG_FILE="$LOG_DIR/mintdev-$(date +%Y%m%d).log"
LOG_LEVEL=${LOG_LEVEL:-"INFO"}  # DEBUG, INFO, WARNING, ERROR, FATAL
VERBOSE=${VERBOSE:-false}
MAX_LOG_FILES=10
MAX_LOG_SIZE_KB=1024  # 1MB

# Función para inicializar el sistema de registro
init_logger() {
    # Verificar si la función ensure_dir existe
    if type ensure_dir &>/dev/null; then
        # Usar la función ensure_dir existente
        ensure_dir "$LOG_DIR"
    else
        # Implementación interna si ensure_dir no está disponible
        if [ ! -d "$LOG_DIR" ]; then
            mkdir -p "$LOG_DIR" || {
                echo "ERROR: No se pudo crear el directorio de logs: $LOG_DIR"
                echo "Usando /tmp como directorio de logs alternativo"
                LOG_DIR="/tmp"
                LOG_FILE="$LOG_DIR/mintdev-$(date +%Y%m%d).log"
            }
        fi
    fi
    
    # Crear archivo de log si no existe
    if [ ! -f "$LOG_FILE" ]; then
        touch "$LOG_FILE" || {
            echo "ERROR: No se pudo crear el archivo de log: $LOG_FILE"
            # Intentar usar un archivo temporal como alternativa
            LOG_FILE="/tmp/mintdev-$(date +%Y%m%d)-$$.log"
            touch "$LOG_FILE"
        }
    fi
    
    # Rotar logs si es necesario
    rotate_logs
    
    # Registrar inicio de sesión
    log_message "INFO" "=== Inicio de sesión de registro $(date) ==="
    log_message "INFO" "Nivel de registro: $LOG_LEVEL"
    log_message "INFO" "Modo detallado: $VERBOSE"
}

# Función para rotar logs
rotate_logs() {
    # Verificar tamaño del archivo de log actual
    if [ -f "$LOG_FILE" ]; then
        local size=$(du -k "$LOG_FILE" | cut -f1)
        if [ "$size" -gt "$MAX_LOG_SIZE_KB" ]; then
            local timestamp=$(date +%Y%m%d%H%M%S)
            mv "$LOG_FILE" "$LOG_FILE.$timestamp"
            touch "$LOG_FILE"
            log_message "INFO" "Archivo de log rotado: $LOG_FILE.$timestamp"
        fi
    fi
    
    # Eliminar archivos de log antiguos si hay demasiados
    local log_count=$(ls -1 "$LOG_DIR"/mintdev-*.log* 2>/dev/null | wc -l)
    if [ "$log_count" -gt "$MAX_LOG_FILES" ]; then
        ls -1t "$LOG_DIR"/mintdev-*.log* | tail -n +$((MAX_LOG_FILES+1)) | xargs rm -f
        log_message "INFO" "Archivos de log antiguos eliminados"
    fi
}

# Función para registrar un mensaje
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    
    # Verificar nivel de registro
    if ! should_log "$level"; then
        return 0
    fi
    
    # Formatear mensaje
    local formatted_message="[$timestamp] [$level] $message"
    
    # Verificar que el directorio de logs existe
    if [ ! -d "$(dirname "$LOG_FILE")" ]; then
        # Intentar crear el directorio
        mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || {
            # Si falla, usar /tmp
            LOG_FILE="/tmp/mintdev-$(date +%Y%m%d)-$$.log"
        }
    fi
    
    # Escribir en archivo de log
    echo "$formatted_message" >> "$LOG_FILE" 2>/dev/null || {
        # Si falla la escritura, intentar con un archivo en /tmp
        LOG_FILE="/tmp/mintdev-$(date +%Y%m%d)-$$.log"
        echo "$formatted_message" >> "$LOG_FILE" 2>/dev/null
    }
    
    # Mostrar en consola si el modo detallado está activado
    if [ "$VERBOSE" = "true" ]; then
        case $level in
            "DEBUG") echo -e "\e[36m$formatted_message\e[0m" ;;
            "INFO") echo -e "\e[32m$formatted_message\e[0m" ;;
            "WARNING") echo -e "\e[33m$formatted_message\e[0m" ;;
            "ERROR") echo -e "\e[31m$formatted_message\e[0m" ;;
            "FATAL") echo -e "\e[1;31m$formatted_message\e[0m" ;;
            *) echo "$formatted_message" ;;
        esac
    fi
}

# Función para verificar si un nivel de registro debe ser registrado
should_log() {
    local level=$1
    
    case $LOG_LEVEL in
        "DEBUG")
            return 0
            ;;
        "INFO")
            if [ "$level" = "DEBUG" ]; then
                return 1
            fi
            return 0
            ;;
        "WARNING")
            if [ "$level" = "DEBUG" ] || [ "$level" = "INFO" ]; then
                return 1
            fi
            return 0
            ;;
        "ERROR")
            if [ "$level" = "DEBUG" ] || [ "$level" = "INFO" ] || [ "$level" = "WARNING" ]; then
                return 1
            fi
            return 0
            ;;
        "FATAL")
            if [ "$level" = "FATAL" ]; then
                return 0
            fi
            return 1
            ;;
        *)
            return 0
            ;;
    esac
}

# Función para obtener los logs más recientes
get_recent_logs() {
    local lines=${1:-50}
    
    if [ -f "$LOG_FILE" ]; then
        tail -n "$lines" "$LOG_FILE"
    else
        echo "No hay archivos de log disponibles"
    fi
}

# Función para buscar en los logs
search_logs() {
    local pattern=$1
    local files=${2:-"$LOG_FILE"}
    
    if [ -z "$pattern" ]; then
        echo "Error: Patrón de búsqueda no especificado"
        return 1
    fi
    
    if [ "$files" = "$LOG_FILE" ]; then
        if [ -f "$LOG_FILE" ]; then
            grep -i "$pattern" "$LOG_FILE"
        else
            echo "No hay archivos de log disponibles"
        fi
    else
        grep -i "$pattern" "$LOG_DIR"/$files
    fi
}

# Función para limpiar logs antiguos
clean_old_logs() {
    local days=${1:-30}
    
    find "$LOG_DIR" -name "mintdev-*.log*" -type f -mtime +"$days" -delete
    log_message "INFO" "Logs antiguos (más de $days días) eliminados"
}

# Función para obtener estadísticas de logs
get_log_stats() {
    if [ ! -d "$LOG_DIR" ]; then
        echo "No hay directorio de logs disponible"
        return 1
    fi
    
    local total_size=$(du -sh "$LOG_DIR" | cut -f1)
    local file_count=$(find "$LOG_DIR" -name "mintdev-*.log*" | wc -l)
    local oldest_file=$(find "$LOG_DIR" -name "mintdev-*.log*" -type f -printf '%T+ %p\n' | sort | head -n 1 | cut -d' ' -f2-)
    local newest_file=$(find "$LOG_DIR" -name "mintdev-*.log*" -type f -printf '%T+ %p\n' | sort -r | head -n 1 | cut -d' ' -f2-)
    
    echo "Estadísticas de logs:"
    echo "- Tamaño total: $total_size"
    echo "- Número de archivos: $file_count"
    echo "- Archivo más antiguo: $oldest_file"
    echo "- Archivo más reciente: $newest_file"
    
    if [ -f "$LOG_FILE" ]; then
        local error_count=$(grep -c "\[ERROR\]" "$LOG_FILE")
        local warning_count=$(grep -c "\[WARNING\]" "$LOG_FILE")
        echo "- Errores en el log actual: $error_count"
        echo "- Advertencias en el log actual: $warning_count"
    fi
}

# Función para exportar logs
export_logs() {
    local output_file=${1:-"$HOME/mintdev-logs-$(date +%Y%m%d).tar.gz"}
    
    if [ ! -d "$LOG_DIR" ]; then
        echo "No hay directorio de logs disponible"
        return 1
    fi
    
    tar -czf "$output_file" -C "$(dirname "$LOG_DIR")" "$(basename "$LOG_DIR")"
    
    if [ $? -eq 0 ]; then
        echo "Logs exportados a: $output_file"
        return 0
    else
        echo "Error al exportar logs"
        return 1
    fi
}

