#!/bin/bash

# Script para generar checksums para los archivos descargados

# Obtener directorio del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Cargar módulos necesarios
source "$SCRIPT_DIR/lib/logger.sh"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/security.sh"
source "$SCRIPT_DIR/lib/banner.sh"

# Mostrar banner
show_verify_banner

print_message "blue" "===== GENERACIÓN DE CHECKSUMS PARA ARCHIVOS ====="
print_message "yellow" "Este script generará checksums SHA-256 para los archivos descargados."
echo ""

# Verificar si existe el directorio de checksums
ensure_dir "$CHECKSUMS_DIR"

# Directorios donde buscar archivos para generar checksums
search_dirs=(
    "/tmp/mint-dev-setup"
    "$SCRIPT_DIR/downloads"
    "$HOME/Downloads"
)

# Extensiones de archivos a considerar
file_extensions=(
    "*.deb"
    "*.tar.gz"
    "*.zip"
    "*.AppImage"
    "*.run"
    "*.sh"
    "*.bin"
    "*.iso"
)

# Contar archivos encontrados
total_files=0
processed_files=0

# Buscar archivos en los directorios especificados
for dir in "${search_dirs[@]}"; do
    if [ ! -d "$dir" ]; then
        continue
    fi
    
    print_message "yellow" "Buscando archivos en: $dir"
    
    for ext in "${file_extensions[@]}"; do
        files=$(find "$dir" -name "$ext" -type f 2>/dev/null)
        
        for file in $files; do
            ((total_files++))
            
            # Verificar si ya existe un checksum para este archivo
            basename=$(basename "$file")
            checksum_file="$CHECKSUMS_DIR/$basename.sha256"
            
            if [ -f "$checksum_file" ]; then
                print_message "yellow" "Ya existe checksum para: $basename (omitiendo)"
                continue
            fi
            
            print_message "yellow" "Generando checksum para: $basename"
            
            # Generar checksum
            if generate_checksum "$file" "sha256"; then
                print_message "green" "✓ Checksum generado: $basename"
                ((processed_files++))
            else
                print_message "red" "✗ Error al generar checksum: $basename"
            fi
        done
    done
done

echo ""
print_message "blue" "===== RESUMEN DE GENERACIÓN DE CHECKSUMS ====="
print_message "green" "Archivos encontrados: $total_files"
print_message "green" "Checksums generados: $processed_files"

if [ "$total_files" -eq 0 ]; then
    print_message "yellow" "⚠️ No se encontraron archivos para generar checksums"
    exit 0
fi

print_message "green" "✓ Proceso de generación de checksums completado"
print_message "yellow" "Los checksums se almacenaron en: $CHECKSUMS_DIR"
print_message "yellow" "Para verificar la integridad de los archivos, ejecute: ./verify-checksums.sh"
exit 0
