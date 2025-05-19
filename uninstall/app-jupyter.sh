#!/bin/bash

# Script de desinstalación para Jupyter en Linux Mint
# Maneja la eliminación del entorno virtual de análisis de datos

# Variables y funciones
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."
source "$SCRIPT_DIR/lib/common.sh"

print_message "blue" "===== DESINSTALANDO JUPYTER Y ENTORNO VIRTUAL DE ANÁLISIS DE DATOS ====="

# Confirmar desinstalación
read -p "¿Estás seguro de que deseas desinstalar Jupyter y el entorno virtual de análisis de datos? (s/n): " confirm
if [[ "$confirm" != [Ss]* ]]; then
    print_message "yellow" "Desinstalación cancelada."
    exit 0
fi

# Definir rutas al entorno virtual
VENV_DIR="$HOME/.venvs"
DATAVENV_NAME="data_analytics"
DATAVENV_PATH="$VENV_DIR/$DATAVENV_NAME"

# Primero eliminamos el acceso directo
if [ -f "$HOME/.local/share/applications/jupyterlab.desktop" ]; then
    rm -f "$HOME/.local/share/applications/jupyterlab.desktop"
    print_message "yellow" "Acceso directo de JupyterLab eliminado"
fi

# Eliminar script de inicio de JupyterLab
if [ -f "$HOME/.local/bin/start-jupyter.sh" ]; then
    rm -f "$HOME/.local/bin/start-jupyter.sh"
    print_message "yellow" "Script de inicio de JupyterLab eliminado"
fi

# Eliminar kernel de IPython registrado
if command -v jupyter &> /dev/null; then
    read -p "¿Eliminar kernel de IPython registrado? (s/n): " confirm_kernel
    if [[ "$confirm_kernel" == [Ss]* ]]; then
        jupyter kernelspec remove -f "$DATAVENV_NAME" 2>/dev/null || true
        print_message "yellow" "Kernel de IPython para análisis de datos eliminado"
    fi
fi

# Eliminar configuración de Jupyter
if [ -d "$HOME/.jupyter" ]; then
    read -p "¿Eliminar archivos de configuración de Jupyter? (s/n): " confirm_config
    if [[ "$confirm_config" == [Ss]* ]]; then
        rm -rf "$HOME/.jupyter"
        print_message "yellow" "Archivos de configuración de Jupyter eliminados"
    fi
fi

# Eliminar entorno virtual de análisis de datos
if [ -d "$DATAVENV_PATH" ]; then
    read -p "¿Eliminar entorno virtual '$DATAVENV_NAME'? (s/n): " confirm_venv
    if [[ "$confirm_venv" == [Ss]* ]]; then
        rm -rf "$DATAVENV_PATH"
        print_message "green" "✓ Entorno virtual de análisis de datos eliminado"
    else
        print_message "yellow" "Entorno virtual '$DATAVENV_NAME' conservado"
    fi
else
    print_message "yellow" "Entorno virtual '$DATAVENV_NAME' no encontrado"
fi

# Eliminar alias en archivos de shell
if [ -f "$HOME/.zshrc" ]; then
    read -p "¿Eliminar alias relacionados con Jupyter y el entorno virtual en .zshrc? (s/n): " confirm_alias
    if [[ "$confirm_alias" == [Ss]* ]]; then
        sed -i '/alias jlab=/d' "$HOME/.zshrc"
        sed -i '/alias datavenv=/d' "$HOME/.zshrc"
        print_message "yellow" "Alias eliminados de .zshrc"
    fi
fi

if [ -f "$HOME/.bashrc" ]; then
    read -p "¿Eliminar alias relacionados con Jupyter y el entorno virtual en .bashrc? (s/n): " confirm_alias
    if [[ "$confirm_alias" == [Ss]* ]]; then
        sed -i '/alias jlab=/d' "$HOME/.bashrc"
        sed -i '/alias datavenv=/d' "$HOME/.bashrc"
        print_message "yellow" "Alias eliminados de .bashrc"
    fi
fi

print_message "green" "✓ Desinstalación de Jupyter y entorno virtual de análisis de datos completada"
print_message "yellow" "Nota: El directorio '$VENV_DIR' que contiene otros entornos virtuales se ha conservado"
