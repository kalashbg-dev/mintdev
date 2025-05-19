#!/bin/bash

# Funciones de seguridad para MintDev Setup
# Incluye verificación de checksums y validación de descargas

# Directorio para almacenar checksums
CHECKSUMS_DIR="$SCRIPT_DIR/checksums"

# Función para verificar si una URL usa HTTPS
verify_https_url() {
    local url=$1
    if [[ "$url" != https://* ]]; then
        log_message "ERROR" "URL insegura detectada: $url"
        print_message "red" "Error: Solo se permiten URLs HTTPS por seguridad."
        print_message "red" "URL proporcionada: $url"
        return 1
    fi
    return 0
}

# Función para descargar un archivo de forma segura
secure_download() {
    local url=$1
    local output_file=$2
    local force=${3:-false}
    
    # Verificar si la URL usa HTTPS
    if ! verify_https_url "$url"; then
        return 1
    fi
    
    # Verificar si el archivo ya existe
    if [ -f "$output_file" ] && [ "$force" != "true" ]; then
        print_message "yellow" "El archivo $output_file ya existe. Omitiendo descarga."
        log_message "INFO" "Omitiendo descarga de archivo existente: $output_file"
        return 0
    fi
    
    # Crear directorio de destino si no existe
    local output_dir=$(dirname "$output_file")
    ensure_dir "$output_dir"
    
    # Descargar el archivo
    print_message "yellow" "Descargando $url a $output_file..."
    log_message "INFO" "Iniciando descarga: $url -> $output_file"
    
    # Usar wget con opciones de seguridad
    wget --https-only --secure-protocol=TLSv1_2 --no-check-certificate \
         -q --show-progress -O "$output_file" "$url"
    
    local status=$?
    if [ $status -ne 0 ]; then
        print_message "red" "Error al descargar $url"
        log_message "ERROR" "Fallo en la descarga: $url (código: $status)"
        return 1
    fi
    
    print_message "green" "✓ Descarga completada: $output_file"
    log_message "INFO" "Descarga completada: $output_file"
    
    # Generar checksum para el archivo descargado
    generate_checksum "$output_file" "sha256"
    
    return 0
}

# Función para generar checksum de un archivo
generate_checksum() {
    local file=$1
    local algorithm=${2:-"sha256"}
    
    # Verificar si el archivo existe
    if [ ! -f "$file" ]; then
        log_message "ERROR" "No se puede generar checksum: archivo no encontrado: $file"
        return 1
    fi
    
    # Crear directorio de checksums si no existe
    ensure_dir "$CHECKSUMS_DIR"
    
    # Nombre base del archivo
    local basename=$(basename "$file")
    local checksum_file="$CHECKSUMS_DIR/${basename}.${algorithm}"
    
    # Generar checksum según el algoritmo
    case $algorithm in
        md5)
            md5sum "$file" | cut -d ' ' -f 1 > "$checksum_file"
            ;;
        sha1)
            sha1sum "$file" | cut -d ' ' -f 1 > "$checksum_file"
            ;;
        sha256)
            sha256sum "$file" | cut -d ' ' -f 1 > "$checksum_file"
            ;;
        sha512)
            sha512sum "$file" | cut -d ' ' -f 1 > "$checksum_file"
            ;;
        *)
            log_message "ERROR" "Algoritmo de checksum no soportado: $algorithm"
            return 1
            ;;
    esac
    
    if [ $? -ne 0 ]; then
        log_message "ERROR" "Error al generar checksum $algorithm para: $file"
        return 1
    fi
    
    log_message "INFO" "Checksum $algorithm generado para: $file -> $checksum_file"
    return 0
}

# Función para verificar checksum de un archivo
verify_checksum() {
    local file=$1
    local algorithm=${2:-"sha256"}
    
    # Verificar si el archivo existe
    if [ ! -f "$file" ]; then
        log_message "ERROR" "No se puede verificar checksum: archivo no encontrado: $file"
        return 1
    fi
    
    # Nombre base del archivo
    local basename=$(basename "$file")
    local checksum_file="$CHECKSUMS_DIR/${basename}.${algorithm}"
    
    # Verificar si existe el archivo de checksum
    if [ ! -f "$checksum_file" ]; then
        log_message "ERROR" "Archivo de checksum no encontrado: $checksum_file"
        return 1
    fi
    
    # Leer checksum almacenado
    local stored_checksum=$(cat "$checksum_file")
    
    # Calcular checksum actual
    local current_checksum=""
    case $algorithm in
        md5)
            current_checksum=$(md5sum "$file" | cut -d ' ' -f 1)
            ;;
        sha1)
            current_checksum=$(sha1sum "$file" | cut -d ' ' -f 1)
            ;;
        sha256)
            current_checksum=$(sha256sum "$file" | cut -d ' ' -f 1)
            ;;
        sha512)
            current_checksum=$(sha512sum "$file" | cut -d ' ' -f 1)
            ;;
        *)
            log_message "ERROR" "Algoritmo de checksum no soportado: $algorithm"
            return 1
            ;;
    esac
    
    # Comparar checksums
    if [ "$stored_checksum" = "$current_checksum" ]; then
        log_message "INFO" "Verificación de checksum exitosa para: $file"
        return 0
    else
        log_message "ERROR" "Verificación de checksum fallida para: $file"
        log_message "ERROR" "Esperado: $stored_checksum"
        log_message "ERROR" "Obtenido: $current_checksum"
        return 1
    fi
}

# Función para verificar la firma GPG de un archivo
verify_gpg_signature() {
    local file=$1
    local signature_file=$2
    local key_id=${3:-""}
    
    # Verificar si los archivos existen
    if [ ! -f "$file" ]; then
        log_message "ERROR" "Archivo no encontrado: $file"
        return 1
    fi
    
    if [ ! -f "$signature_file" ]; then
        log_message "ERROR" "Archivo de firma no encontrado: $signature_file"
        return 1
    fi
    
    # Verificar si gpg está instalado
    if ! command -v gpg &> /dev/null; then
        log_message "ERROR" "gpg no está instalado"
        print_message "red" "Error: gpg no está instalado. Instálalo con: sudo apt install gnupg"
        return 1
    fi
    
    # Si se proporciona un ID de clave, importarla primero
    if [ -n "$key_id" ]; then
        log_message "INFO" "Importando clave GPG: $key_id"
        gpg --keyserver keyserver.ubuntu.com --recv-keys "$key_id"
        if [ $? -ne 0 ]; then
            log_message "ERROR" "Error al importar clave GPG: $key_id"
            return 1
        fi
    fi
    
    # Verificar la firma
    log_message "INFO" "Verificando firma GPG: $file con $signature_file"
    gpg --verify "$signature_file" "$file"
    
    if [ $? -ne 0 ]; then
        log_message "ERROR" "Verificación de firma GPG fallida para: $file"
        return 1
    fi
    
    log_message "INFO" "Verificación de firma GPG exitosa para: $file"
    return 0
}
