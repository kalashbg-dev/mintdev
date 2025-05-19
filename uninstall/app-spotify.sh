#!/bin/bash

# Script de desinstalación para Spotify en Linux Mint
sudo apt purge --auto-remove -y spotify-client
sudo rm /etc/apt/sources.list.d/spotify.list
sudo rm /etc/apt/trusted.gpg.d/spotify.gpg
echo "Spotify desinstalado correctamente"
