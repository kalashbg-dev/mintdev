#!/bin/bash

# Script de desinstalación para Ulauncher en Linux Mint
sudo apt purge --auto-remove -y ulauncher
sudo add-apt-repository --remove -y ppa:agornostal/ulauncher
rm -rf ~/.config/ulauncher
rm -rf ~/.config/autostart/ulauncher.desktop
echo "Ulauncher desinstalado correctamente"
