#!/bin/bash

# Script de desinstalación para PostgreSQL en Linux Mint
sudo systemctl stop postgresql
sudo apt purge --auto-remove -y postgresql postgresql-contrib
sudo rm -rf /var/lib/postgresql/
sudo rm -rf /etc/postgresql/
echo "PostgreSQL desinstalado correctamente"
