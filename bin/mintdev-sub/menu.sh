#!/bin/bash

# Ensure gum is installed
if ! command -v gum &> /dev/null; then
    echo "The 'gum' utility is required for the menu but is not installed."
    echo "Please ensure the bootstrap process has completed successfully."
    exit 1
fi

if [ $# -eq 0 ]; then
	SUB=$(gum choose "Theme" "Update" "Install" "Uninstall" "Quit" --height 10 --header "" | tr '[:upper:]' '[:lower:]')
else
	SUB=$1
fi

[ -n "$SUB" ] && [ "$SUB" != "quit" ] && bash "$MINTDEV_PATH/bin/mintdev-sub/$SUB.sh"
