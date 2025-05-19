#!/bin/bash

# Script para restaurar la configuración de escritorio Cinnamon a valores predeterminados

echo "Restaurando configuración de atajos de teclado..."
gsettings reset-recursively org.cinnamon.desktop.keybindings

echo "Restaurando configuración de tema..."
gsettings set org.cinnamon.desktop.interface gtk-theme "Mint-Y"
gsettings set org.cinnamon.desktop.wm.preferences theme "Mint-Y"
gsettings set org.cinnamon.theme name "Mint-Y"
gsettings set org.cinnamon.desktop.interface icon-theme "Mint-Y"
gsettings set org.cinnamon.desktop.interface cursor-theme "DMZ-White"

echo "Restaurando configuración del panel..."
# Restaurar panel a configuración predeterminada
gsettings reset org.cinnamon panels-enabled
gsettings reset org.cinnamon enabled-applets

echo "Restaurando configuración de fuente..."
gsettings reset org.cinnamon.desktop.interface font-name
gsettings reset org.cinnamon.desktop.interface document-font-name
gsettings reset org.cinnamon.desktop.interface monospace-font-name
gsettings reset org.cinnamon.desktop.wm.preferences titlebar-font

echo "Restaurando terminal predeterminada..."
gsettings reset org.cinnamon.desktop.default-applications.terminal exec

echo "Configuración de escritorio restaurada a valores predeterminados"
