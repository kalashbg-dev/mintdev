#!/bin/bash

# Script de desinstalación para Variety (gestor de fondos de pantalla) en Linux Mint
sudo apt purge --auto-remove -y variety
rm -rf ~/.config/variety
rm -rf ~/.config/autostart/variety.desktop
echo "Variety desinstalado correctamente"
