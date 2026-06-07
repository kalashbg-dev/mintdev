#!/bin/bash

# Apply Cinnamon theme based on current mintdev theme
apply_cinnamon_theme() {
    local theme_id=$1
    local gsettings_theme="Mint-Y-Dark"
    local gsettings_icon="Mint-Y"

    case "$theme_id" in
        "tokyo-night"|"dracula"|"rose-pine")
            gsettings_theme="Mint-Y-Dark-Purple"
            gsettings_icon="Mint-Y-Purple"
            ;;
        "nord")
            gsettings_theme="Mint-Y-Dark-Aqua"
            gsettings_icon="Mint-Y-Aqua"
            ;;
        "everforest"|"osaka-jade")
            gsettings_theme="Mint-Y-Dark-Teal"
            gsettings_icon="Mint-Y-Teal"
            ;;
        "gruvbox"|"ristretto")
            gsettings_theme="Mint-Y-Dark-Orange"
            gsettings_icon="Mint-Y-Orange"
            ;;
        "catppuccin")
            gsettings_theme="Mint-Y-Dark-Pink"
            gsettings_icon="Mint-Y-Pink"
            ;;
        "matte-black")
            gsettings_theme="Mint-Y-Dark-Grey"
            gsettings_icon="Mint-Y-Grey"
            ;;
        *)
            gsettings_theme="Mint-Y-Dark"
            gsettings_icon="Mint-Y"
            ;;
    esac

    # Ensure gsettings is available (it might not be during some headless checks)
    if command -v gsettings &> /dev/null; then
        gsettings set org.cinnamon.desktop.interface gtk-theme "$gsettings_theme"
        gsettings set org.cinnamon.desktop.wm.preferences theme "$gsettings_theme"
        gsettings set org.cinnamon.theme name "$gsettings_theme"
        gsettings set org.cinnamon.desktop.interface icon-theme "$gsettings_icon"
    fi
}
