#!/bin/bash

# Script de desinstalación para Conky en Linux Mint
sudo apt purge --auto-remove -y conky-all
rm -rf ~/.config/conky
rm -rf ~/.config/autostart/conky.desktop
echo "Conky desinstalado correctamente"
