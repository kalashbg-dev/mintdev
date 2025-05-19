#!/bin/bash

# Script de desinstalación para GitHub CLI en Linux Mint
sudo apt purge --auto-remove -y gh
sudo rm /etc/apt/sources.list.d/github-cli.list
sudo rm /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "GitHub CLI desinstalado correctamente"
