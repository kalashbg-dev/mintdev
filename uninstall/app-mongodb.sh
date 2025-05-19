#!/bin/bash

# Script de desinstalación para MongoDB en Linux Mint
sudo systemctl stop mongod
sudo apt purge --auto-remove -y mongodb-org
sudo rm -rf /var/lib/mongodb
sudo rm -rf /var/log/mongodb
sudo rm /etc/apt/sources.list.d/mongodb-org-*.list
echo "MongoDB desinstalado correctamente"
