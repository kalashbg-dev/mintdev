#!/bin/bash

# Script de desinstalación para Zsh y Oh My Zsh en Linux Mint

# Variables y funciones
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."
source "$SCRIPT_DIR/lib/common.sh"

print_message "blue" "===== DESINSTALANDO ZSH Y OH MY ZSH ====="

# Confirmar desinstalación
read -p "¿Estás seguro de que deseas desinstalar Zsh y Oh My Zsh? (s/n): " confirm
if [[ "$confirm" != [Ss]* ]]; then
    print_message "yellow" "Desinstalación de Zsh y Oh My Zsh cancelada."
    exit 0
fi

# Cambiar shell predeterminada a bash si está usando zsh
if [[ "$SHELL" == *"zsh"* ]]; then
    print_message "yellow" "Cambiando la shell predeterminada a bash..."
    chsh -s $(which bash)
    if [ $? -eq 0 ]; then
        print_message "green" "✓ Shell predeterminada cambiada a bash"
    else
        print_message "red" "✗ No se pudo cambiar la shell predeterminada. Ejecútalo manualmente con: chsh -s $(which bash)"
    fi
fi

# Desinstalar Oh My Zsh si está instalado
if [ -d "$HOME/.oh-my-zsh" ]; then
    print_message "yellow" "Desinstalando Oh My Zsh..."
    
    # Hacer copia de seguridad de .zshrc si existe
    if [ -f "$HOME/.zshrc" ]; then
        backup_file "$HOME/.zshrc"
        print_message "yellow" "Archivo .zshrc respaldado"
    fi
    
    # Usar el uninstall.sh de Oh My Zsh
    if [ -f "$HOME/.oh-my-zsh/tools/uninstall.sh" ]; then
        zsh -c "source $HOME/.oh-my-zsh/tools/uninstall.sh --yes"
        print_message "green" "✓ Oh My Zsh desinstalado correctamente"
    else
        print_message "yellow" "Eliminando directorio Oh My Zsh manualmente..."
        rm -rf "$HOME/.oh-my-zsh"
        print_message "green" "✓ Directorio Oh My Zsh eliminado"
    fi
else
    print_message "yellow" "Oh My Zsh no está instalado"
fi

# Eliminar plugins adicionales
if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    rm -rf "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
    print_message "yellow" "Plugin zsh-autosuggestions eliminado"
fi

if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    rm -rf "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
    print_message "yellow" "Plugin zsh-syntax-highlighting eliminado"
fi

if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    rm -rf "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    print_message "yellow" "Tema powerlevel10k eliminado"
fi

# Preguntar si desea desinstalar Zsh
read -p "¿Deseas desinstalar completamente Zsh del sistema? (s/n): " confirm_zsh
if [[ "$confirm_zsh" == [Ss]* ]]; then
    print_message "yellow" "Desinstalando Zsh..."
    sudo apt remove --purge -y zsh
    sudo apt autoremove -y
    print_message "green" "✓ Zsh desinstalado completamente"
else
    print_message "yellow" "Zsh permanece instalado en el sistema"
fi

print_message "green" "✓ Desinstalación de Zsh y Oh My Zsh completada"
print_message "yellow" "Es necesario cerrar sesión y volver a iniciarla para que los cambios tengan efecto completo"
