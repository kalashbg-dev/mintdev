#!/bin/bash

# Define themes statically for gum or dynamically from index.json
if command -v jq &> /dev/null; then
    THEME_NAMES=$(jq -r '.themes[].name' "$MINTDEV_PATH/themes/index.json")
else
    THEME_NAMES="Tokyo Night\nNord\nGruvbox\nDracula\nCatppuccin\nEverforest\nKanagawa\nRosé Pine\nOsaka Jade\nMatte Black\nRistretto"
fi

echo "Choose your theme:"
SELECTED_NAME=$(echo -e "$THEME_NAMES" | gum choose --height 15)

if [ -z "$SELECTED_NAME" ]; then
    exit 0
fi

# Get the ID for the selected theme
if command -v jq &> /dev/null; then
    SELECTED_ID=$(jq -r --arg name "$SELECTED_NAME" '.themes[] | select(.name == $name) | .id' "$MINTDEV_PATH/themes/index.json")
else
    # Basic fallback mapping
    SELECTED_ID=$(echo "$SELECTED_NAME" | tr '[:upper:]' '[:lower:]' | tr -d 'é' | sed 's/ /-/g')
fi

echo "Applying theme: $SELECTED_NAME ($SELECTED_ID)"

export THEME_NAME="$SELECTED_ID"
export SCRIPT_DIR="$MINTDEV_PATH"

# Call the theme manager
source "$MINTDEV_PATH/lib/theme-manager.sh"
# Fix to call the correct function inside the original script:
apply_theme_system_wide "$SELECTED_ID"

gum spin --spinner dot --title "Applying theme..." -- sleep 2
clear
bash "$MINTDEV_PATH/bin/mintdev"
