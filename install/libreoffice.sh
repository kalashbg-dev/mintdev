#!/bin/bash

# Script de instalación para LibreOffice en Linux Mint

# Obtener directorio del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../lib/common.sh"

print_message "blue" "===== INSTALANDO LIBREOFFICE ====="
if ! is_installed libreoffice; then
    sudo apt install -y libreoffice libreoffice-gtk3 libreoffice-style-sifr
    
    # Dependiendo del tema seleccionado, configurar estilo de iconos y tema
    case $THEME_NAME in
        "tokyo-night" | "dracula" | "catppuccin")
            # Usar tema oscuro para estos temas
            print_message "yellow" "Configurando tema oscuro para LibreOffice..."
            mkdir -p "$HOME/.config/libreoffice/4/user/config/"
            cat > "$HOME/.config/libreoffice/4/user/config/libreoffice.xcu" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<oor:items xmlns:oor="http://openoffice.org/2001/registry" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<item oor:path="/org.openoffice.Office.Common/Misc"><prop oor:name="SymbolStyle" oor:op="fuse"><value>sifr</value></prop></item>
<item oor:path="/org.openoffice.Office.Common/Misc"><prop oor:name="SymbolSet" oor:op="fuse"><value>0</value></prop></item>
<item oor:path="/org.openoffice.Office.Common/Accessibility"><prop oor:name="AutoDetectSystemHC" oor:op="fuse"><value>false</value></prop></item>
<item oor:path="/org.openoffice.Office.Common/Accessibility"><prop oor:name="UseSystemColors" oor:op="fuse"><value>false</value></prop></item>
<item oor:path="/org.openoffice.Office.Common/Misc"><prop oor:name="UseOpenCL" oor:op="fuse"><value>false</value></prop></item>
<item oor:path="/org.openoffice.Office.Common/Help"><prop oor:name="ExtendedTip" oor:op="fuse"><value>true</value></prop></item>
</oor:items>
EOF
            ;;
        *)
            # Usar tema claro para otros temas
            print_message "yellow" "Configurando tema claro para LibreOffice..."
            ;;
    esac
    
    check_success "Instalación y configuración de LibreOffice"
else
    print_message "yellow" "LibreOffice ya está instalado"
fi
