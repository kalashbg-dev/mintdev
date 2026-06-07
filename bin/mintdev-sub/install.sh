#!/bin/bash

# Ensure gum is installed
if ! command -v gum &> /dev/null; then
    echo "The 'gum' utility is required."
    exit 1
fi

APPS=(
	"Discord"
	"Brave"
	"Ollama"
	"Cursor"
	"<< Back"
)

echo "Choose an application to install:"
CHOICE=$(gum choose "${APPS[@]}" --height 10)

if [[ "$CHOICE" == "<< Back"* ]] || [[ -z "$CHOICE" ]]; then
	clear
	bash "$MINTDEV_PATH/bin/mintdev"
	exit 0
fi

# Map Choice to script name
INSTALLER=$(echo "$CHOICE" | tr '[:upper:]' '[:lower:]')

# Run installer script
if [ -f "$MINTDEV_PATH/install/optional/app-${INSTALLER}.sh" ]; then
    bash "$MINTDEV_PATH/install/optional/app-${INSTALLER}.sh"
    echo "Installation finished for $CHOICE."
else
    echo "Installer for $CHOICE not found at install/optional/app-${INSTALLER}.sh"
fi

sleep 2
clear
bash "$MINTDEV_PATH/bin/mintdev"
