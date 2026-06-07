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

echo "Choose an application to UNINSTALL:"
CHOICE=$(gum choose "${APPS[@]}" --height 10)

if [[ "$CHOICE" == "<< Back"* ]] || [[ -z "$CHOICE" ]]; then
	clear
	bash "$MINTDEV_PATH/bin/mintdev"
	exit 0
fi

# We don't have uninstaller scripts yet, but we will mock the functionality
echo "Uninstalling $CHOICE..."
gum spin --spinner dot --title "Processing removal..." -- sleep 2
echo "$CHOICE has been queued for removal. (To be implemented fully)"

sleep 2
clear
bash "$MINTDEV_PATH/bin/mintdev"
