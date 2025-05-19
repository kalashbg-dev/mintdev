#!/bin/bash

# Script para verificar la integridad de los archivos descargados
# mediante checksums

# Obtener directorio del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Cargar módulos necesarios
source "$SCRIPT_DIR/lib/logger.sh"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/security.sh"
source "$SCRIPT_DIR/lib/banner.sh"

# Mostrar banner
show_verify_banner

print_message "blue" "===== VERIFICACIÓN DE INTEGRIDAD DE ARCHIVOS ====="
print_message "yellow" "Este script verificará la integridad de los archivos descargados"
print_message "yellow" "mediante checksums SHA-256."
echo ""

# Verificar si existe el directorio de checksums
if [ ! -d "$CHECKSUMS_DIR" ]; then
    print_message "red" "Error: No se encontró el directorio de checksums"
    print_message "red" "Ejecute primero el script de instalación para generar checksums"
    exit 1
fi

# Contar archivos con checksums
checksum_files=$(find "$CHECKSUMS_DIR" -name "*.sha256" | wc -l)

if [ "$checksum_files" -eq 0 ]; then
    print_message "red" "Error: No se encontraron checksums para verificar"
    print_message "red" "Ejecute primero el script de instalación para generar checksums"
    exit 1
fi

print_message "blue" "Se encontraron $checksum_files archivos con checksums para verificar"
echo ""

# Verificar cada archivo
success_count=0
failed_count=0

for checksum_file in "$CHECKSUMS_DIR"/*.sha256; do
    # Obtener nombre base del archivo
    basename=$(basename "$checksum_file" .sha256)
    
    # Buscar el archivo original
    original_file=""
    
    # Buscar en directorios comunes
    possible_locations=(
        "/tmp/mint-dev-setup"
        "$SCRIPT_DIR/downloads"
        "$HOME/Downloads"
    )
    
    for location in "${possible_locations[@]}"; do
        if [ -f "$location/$basename" ]; then
            original_file="$location/$basename"
            break
        fi
    done
    
    if [ -z "$original_file" ]; then
        print_message "yellow" "⚠️ No se encontró el archivo original para: $basename"
        ((failed_count++))
        continue
    fi
    
    print_message "yellow" "Verificando: $basename..."
    
    # Verificar checksum
    if verify_checksum "$original_file" "sha256"; then
        print_message "green" "✓ Verificación exitosa: $basename"
        ((success_count++))
    else
        print_message "red" "✗ Verificación fallida: $basename"
        print_message "red" "  El archivo puede estar corrupto o haber sido modificado"
        ((failed_count++))
    fi
done

echo ""
print_message "blue" "===== RESUMEN DE VERIFICACIÓN ====="
print_message "green" "Archivos verificados correctamente: $success_count"
print_message "red" "Archivos con verificación fallida: $failed_count"

if [ "$failed_count" -eq 0 ]; then
    print_message "green" "✓ Todos los archivos pasaron la verificación de integridad"
    exit 0
else
    print_message "red" "✗ Algunos archivos no pasaron la verificación de integridad"
    print_message "yellow" "Se recomienda volver a descargar los archivos fallidos"
    exit 1
fi
