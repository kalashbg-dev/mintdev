#!/bin/bash

# Update script logic
gum spin --spinner dot --title "Checking for updates and running migrations..." -- sleep 1

if [ -f "$MINTDEV_PATH/bin/mintdev-sub/migrate.sh" ]; then
    bash "$MINTDEV_PATH/bin/mintdev-sub/migrate.sh"
else
    echo "Migration script not found."
    sleep 2
fi

clear
bash "$MINTDEV_PATH/bin/mintdev"
