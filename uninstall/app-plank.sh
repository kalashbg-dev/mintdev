#!/bin/bash

# Script de desinstalación para Plank Dock en Linux Mint
sudo apt purge --auto-remove -y plank
rm -rf ~/.config/plank
rm -rf ~/.config/autostart/plank.desktop
echo "Plank Dock desinstalado correctamente"
