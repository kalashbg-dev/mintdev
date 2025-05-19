#!/bin/bash

# ---------------------------------------------------------------
# Linux Mint Cinnamon 22.1 Developer Environment Setup Script
# ---------------------------------------------------------------
# This script automates the setup of a complete development
# environment on Linux Mint Cinnamon 22.1, including:
#   - System updates
#   - Development tools
#   - Terminal customization (with themes)
#   - Programming languages and frameworks
#   - Database systems
#   - Container tools
#   - IDE and productivity applications
#   - Desktop environment configuration
#   - System monitoring and appearance customization
# ---------------------------------------------------------------

# Enable error handling
set -e

# Script variables
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIG_DIR="$HOME/.config"
TEMP_DIR="/tmp/mint-dev-setup"
FONTS_DIR="$HOME/.local/share/fonts"
LOG_FILE="$HOME/mint-dev-setup.log"
THEME_NAME="tokyo-night" # Default theme, can be changed via interactive menu

# Cargar módulos en orden correcto
# Las funciones comunes, logger, idempotencia, etc. están en estos archivos
if [ -f "$SCRIPT_DIR/lib/logger.sh" ] && \
   [ -f "$SCRIPT_DIR/lib/common.sh" ] && \
   [ -f "$SCRIPT_DIR/lib/security.sh" ] && \
   [ -f "$SCRIPT_DIR/lib/idempotence.sh" ] && \
   [ -f "$SCRIPT_DIR/lib/theme-manager.sh" ] && \
   [ -f "$SCRIPT_DIR/lib/banner.sh" ]; then

    # Asegurar que el directorio de logs existe antes de cargar el logger
    LOG_DIR="$HOME/.mintdev/logs"
    mkdir -p "$LOG_DIR" 2>/dev/null # ensure_dir is loaded from common.sh after logger
    
    # Cargar módulos
    source "$SCRIPT_DIR/lib/logger.sh"
    # Inicializar sistema de registro (usando función de logger.sh)
    if type init_logger &>/dev/null; then
        init_logger
    else
        # Fallback logging if init_logger is not available
        exec > >(tee -a "$LOG_FILE") 2>&1
        echo "$(date) - Fallback: Logger module not fully loaded. Logging to $LOG_FILE"
    fi
    
    # Cargar los demás módulos después del logger
    source "$SCRIPT_DIR/lib/common.sh"
    source "$SCRIPT_DIR/lib/security.sh" # Assumes secure_download might be here
    source "$SCRIPT_DIR/lib/idempotence.sh" # Assumes is_component_installed, mark_component_installed are here
    source "$SCRIPT_DIR/lib/theme-manager.sh" # Assumes theme management functions are here
    source "$SCRIPT_DIR/lib/banner.sh" # Assumes show_welcome_banner is here
    
    # Verificar si las funciones esenciales de common están cargadas
    if ! type print_message &>/dev/null || ! type check_success &>/dev/null || ! type ensure_dir &>/dev/null || ! type backup_file &>/dev/null || ! type is_installed &>/dev/null; then
         log_message "ERROR" "Essential functions from common.sh not loaded!"
         echo "Error: No se pudieron cargar funciones esenciales desde lib/common.sh. ¿Están definidas allí?"
         exit 1 # Exit if essential functions aren't available
    fi

else
    # Fallback si los módulos no están disponibles
    # Start logging (basic fallback)
    LOG_FILE="$HOME/mint-dev-setup.log"
    echo "WARNING: Library modules not found in $SCRIPT_DIR/lib/. Basic functionality only." | tee -a "$LOG_FILE"
    exec > >(tee -a "$LOG_FILE") 2>&1 # Redirect stdout and stderr to tee
    echo "$(date) - Starting Linux Mint Developer Environment Setup (Fallback Mode)"
    
    # Define essential fallback functions if common.sh is missing
    print_message() { local color=$1; local message=$2; echo "$message"; }
    check_success() { if [ $? -eq 0 ]; then echo "Success: $1"; else echo "Failed: $1"; read -p "Continue anyway? (y/n):" c; if [[ "$c" != "y" ]]; then exit 1; fi; fi; }
    ensure_dir() { mkdir -p "$1" 2>/dev/null; }
    backup_file() { if [ -f "$1" ]; then cp "$1" "$1.backup.$(date +%Y%m%d%H%M%S)"; fi; }
    is_installed() { dpkg -l "$1" &> /dev/null || command -v "$1" &> /dev/null; } # Basic check

    # Define placeholder functions if other modules are missing
    log_message() { echo "$(date) [$1] $2"; } # Basic logging
    init_logger() { echo "Fallback logger initialized."; }
    show_welcome_banner() { echo "Welcome to MintDev Setup (Fallback Mode)"; }
    list_available_themes() { echo "tokyo-night - Tokyo Night: Dark blue/purple theme\nnord - Nord: Cool blue arctic theme"; } # Example
    set_current_theme() { echo "Setting theme (fallback): $1"; }
    is_component_installed() { is_installed "$1"; } # Use is_installed as fallback
    mark_component_installed() { echo "Marking component installed (fallback): $1"; }
    # Note: theme application functions (apply_theme_to_alacritty, etc.) are NOT defined in fallback
    # jq dependency check needs common.sh functions, add fallback here too?
    command_exists() { command -v "$1" &> /dev/null; } # Need command_exists for jq check
    check_and_install_jq() {
        if command_exists jq; then echo "'jq' is installed."; return 0; fi
        echo "'jq' not found. Cannot install automatically in fallback. Please install it manually.";
        echo "Example: sudo apt update && sudo apt install jq";
        return 1;
    }
fi

# --- Dependency Check and Installation (using functions from common.sh or fallback) ---
# Call the check and install function.
# If this function returns non-zero, the script should exit.
# Check for command_exists before calling check_and_install_jq
if type check_and_install_jq &>/dev/null; then
    if ! check_and_install_jq; then
        print_message "red" "Required dependencies not met. Aborting."
        exit 1
    fi
else
     print_message "red" "Dependency check function (check_and_install_jq) not available! Aborting."
     exit 1 # Cannot proceed without dependency check logic
fi


# Function to check environment compatibility (uses common.sh functions internally)
check_environment() {
    print_message "blue" "===== Checking Environment Compatibility ====="
    if type log_message &>/dev/null; then log_message "INFO" "Checking environment compatibility"; fi

    # Use get_system_version from common.sh
    local MINT_VERSION=$(get_system_version)
    local EXPECTED_VERSION="22.1"

    if [ "$MINT_VERSION" == "unknown" ]; then
        print_message "red" "Error: Could not determine system version. Aborting."
        if type log_message &>/dev/null; then log_message "ERROR" "Could not determine system version."; fi
        exit 1
    fi

    # Use check_system_compatibility from common.sh
    if ! check_system_compatibility "$EXPECTED_VERSION"; then
         print_message "yellow" "⚠️ Warning: This script is designed for Linux Mint $EXPECTED_VERSION, but you're running $MINT_VERSION"
         if type log_message &>/dev/null; then log_message "WARNING" "Running on Linux Mint $MINT_VERSION instead of $EXPECTED_VERSION"; fi
         read -p "Do you want to continue anyway? (y/n): " continue_anyway
         if [[ "$continue_anyway" != "y" ]]; then
             print_message "red" "Aborting installation."
             exit 1
         fi
    else
         print_message "green" "✓ System version ($MINT_VERSION) is compatible or newer than $EXPECTED_VERSION."
         if type log_message &>/dev/null; then log_message "INFO" "System version ($MINT_VERSION) compatibility check passed."; fi
    fi


    if [[ "$XDG_CURRENT_DESKTOP" != *"Cinnamon"* ]]; then
        print_message "yellow" "⚠️ Warning: This script is optimized for Cinnamon desktop environment"
        if type log_message &>/dev/null; then log_message "WARNING" "Not running on Cinnamon desktop environment"; fi
        read -p "Do you want to continue anyway? (y/n): " continue_anyway
        if [[ "$continue_anyway" != "y" ]]; then
            print_message "red" "Aborting installation."
            exit 1
        fi
    else
         print_message "green" "✓ Running on Cinnamon desktop environment."
         if type log_message &>/dev/null; then log_message "INFO" "Running on Cinnamon desktop environment."; fi
    fi

    # Use check_disk_space from common.sh
    local MIN_DISK_SPACE="5" # GB
    if ! check_disk_space "$MIN_DISK_SPACE"; then
         print_message "red" "⚠️ Warning: Less than ${MIN_DISK_SPACE}GB of free disk space available. ($FREE_SPACE GB was found by common.sh)"
         if type log_message &>/dev/null; then log_message "WARNING" "Less than ${MIN_DISK_SPACE}GB of free disk space."; fi
         read -p "This setup requires at least ${MIN_DISK_SPACE}GB of free space. Continue anyway? (y/n): " continue_space
         if [[ "$continue_space" != "y" ]]; then
             print_message "red" "Aborting installation."
             exit 1
         fi
    else
         print_message "green" "✓ Sufficient disk space available."
         if type log_message &>/dev/null; then log_message "INFO" "Sufficient disk space available."; fi
    fi

    # Use check_internet_connection from common.sh
    if ! check_internet_connection; then
        print_message "red" "Error: No internet connection. Aborting."
        if type log_message &>/dev/null; then log_message "ERROR" "No internet connection."; fi
        exit 1
    else
        print_message "green" "✓ Internet connection available."
        if type log_message &>/dev/null; then log_message "INFO" "Internet connection available."; fi
    fi

    # Use check_sudo_permissions from common.sh
    check_sudo_permissions # This function prints its own warning
    if type log_message &>/dev/null; then log_message "INFO" "Sudo permissions check complete."; fi

    print_message "green" "Environment checks complete."
    if type log_message &>/dev/null; then log_message "INFO" "Environment checks complete."; fi
}


# Function to select theme (Uses theme-manager.sh functions)
select_theme() {
    print_message "blue" "===== SELECT VISUAL THEME ====="
    echo "Available themes:"

    # Si tenemos el sistema de gestión de temas, usarlo para listar los temas
    if type list_available_themes &>/dev/null; then
        themes_list=$(list_available_themes)
        if [ -z "$themes_list" ]; then
            print_message "red" "Error: No themes found in index.json or list_available_themes failed."
            if type log_message &>/dev/null; then log_message "ERROR" "No themes found or list_available_themes failed."; fi
            # Fallback to hardcoded themes if listing fails
             echo "Using hardcoded themes as fallback."
             themes_list=$(echo -e "tokyo-night - Tokyo Night: Dark blue/purple theme\nnord - Nord: Cool blue arctic theme\ngruvbox - Gruvbox: Warm, earthy theme\ndracula - Dracula: Dark purple vampire theme\ncatppuccin - Catppuccin: Pastel theme with multiple flavors\neverforest - Everforest: Green forest-inspired theme\nkanagawa - Kanagawa: Japanese wave-inspired theme\nrose-pine - Rose Pine: Elegant pink and purple theme")

             if [ -z "$themes_list" ]; then
                print_message "red" "Fatal Error: No themes available even with fallback. Cannot continue."
                if type log_message &>/dev/null; then log_message "FATAL" "No themes available even with fallback."; fi
                exit 1
             fi
        fi

        echo "$themes_list" | nl -w2 -s') '

        # Obtener el número de temas disponibles
        theme_count=$(echo "$themes_list" | wc -l)

        read -p "Select theme number [1-$theme_count] (default: 1): " theme_selection

        # Validar la selección
        if [[ ! "$theme_selection" =~ ^[0-9]+$ ]] || [ "$theme_selection" -lt 1 ] || [ "$theme_selection" -gt "$theme_count" ]; then
            theme_selection=1
        fi

        # Obtener el ID del tema seleccionado
        selected_theme_line=$(echo "$themes_list" | sed -n "${theme_selection}p")
        THEME_NAME=$(echo "$selected_theme_line" | awk '{print $1}') # Get the first word (ID)
        theme_display_name=$(echo "$selected_theme_line" | cut -d' ' -f3- | sed 's/: .*$//') # Get name and description

        print_message "cyan" "$theme_display_name theme selected (ID: $THEME_NAME)"
        if type log_message &>/dev/null; then
            log_message "INFO" "Theme selected: $THEME_NAME ($theme_display_name)"
        fi
    else
        # Fallback si no tenemos el sistema de gestión de temas
        print_message "yellow" "Theme manager module not loaded. Using hardcoded themes."
        if type log_message &>/dev/null; then log_message "WARNING" "Theme manager module not loaded. Using hardcoded themes."; fi

        echo "1) Tokyo Night (Dark blue/purple theme)"
        echo "2) Catppuccin (Pastel theme with multiple flavors)"
        echo "3) Nord (Cool blue arctic theme)"
        echo "4) Gruvbox (Warm, earthy theme)"
        echo "5) Dracula (Dark purple vampire theme)"
        echo "6) Everforest (Green forest-inspired theme)"
        echo "7) Kanagawa (Japanese wave-inspired theme)"
        echo "8) Rose Pine (Elegant pink and purple theme)"

        read -p "Select theme number [1-8] (default: 1): " theme_selection

        case $theme_selection in
            2) THEME_NAME="catppuccin"; print_message "magenta" "Catppuccin theme selected";;
            3) THEME_NAME="nord"; print_message "cyan" "Nord theme selected";;
            4) THEME_NAME="gruvbox"; print_message "yellow" "Gruvbox theme selected";;
            5) THEME_NAME="dracula"; print_message "magenta" "Dracula theme selected";;
            6) THEME_NAME="everforest"; print_message "green" "Everforest theme selected";;
            7) THEME_NAME="kanagawa"; print_message "blue" "Kanagawa theme selected";;
            8) THEME_NAME="rose-pine"; print_message "magenta" "Rose Pine theme selected";;
            *) THEME_NAME="tokyo-night"; print_message "blue" "Tokyo Night theme selected";;
        esac
        if type log_message &>/dev/null; then log_message "INFO" "Theme selected (hardcoded fallback): $THEME_NAME"; fi
    fi

    # Exportar la variable de tema para que esté disponible en los módulos
    export THEME_NAME

    # Actualizar el tema actual en el archivo de estado usando theme-manager.sh function
    if type set_current_theme &>/dev/null; then
        set_current_theme "$THEME_NAME"
        if type log_message &>/dev/null; then log_message "INFO" "Current theme state updated."; fi
    else
        if type log_message &>/dev/null; then log_message "WARNING" "set_current_theme function not available."; fi
    fi
}


# Function to show interactive menu for component selection
show_interactive_menu() {
    print_message "blue" "===== SELECT COMPONENTS TO INSTALL ====="
    echo "Select which components you want to install:"

    # Development tools
    read -p "Install development tools (Python, Node.js, Docker, GitHub CLI, Rust, Zellij)? (Y/n): " install_dev
    install_dev=${install_dev:-y}

    # Data science tools
    read -p "Install data science tools (Jupyter, pandas, numpy, etc.)? (Y/n): " install_data

    # Databases
    read -p "Install databases (PostgreSQL, MongoDB)? (Y/n): " install_db
    install_db=${install_db:-y}

    # Desktop applications
    read -p "Install desktop applications (VS Code, Spotify, LibreOffice)? (Y/n): " install_apps
    install_apps=${install_apps:-y}

    # Communication tools
    read -p "Install communication tools (Slack, Telegram, Discord, WhatsApp)? (Y/n): " install_comm
    install_comm=${install_comm:-y}

     # API development tools
    read -p "Install API development tools (Postman, Insomnia)? (Y/n): " install_api
    install_api=${install_api:-y}


    # System customizations
    read -p "Install system customizations (Conky, Plank dock, Ulauncher, Variety)? (Y/n): " install_custom
    install_custom=${install_custom:-y}

    # Terminal tools
    read -p "Install terminal tools (Zsh, Alacritty, Tmux, Starship, Micro, Bat, Ranger, Neofetch)? (Y/n): " install_terminal
    install_terminal=${install_terminal:-y}

    # Security tools
    read -p "Install security tools (UFW, ClamAV, fail2ban)? (Y/n): " install_security
    install_security=${install_security:-y}

    # Virtualization
    read -p "Install virtualization tools (VirtualBox, QEMU)? (Y/n): " install_vm
    install_vm=${install_vm:-y}

    # Confirm selections
    echo ""
    print_message "yellow" "You have selected to install:"
    [[ "$install_dev" == [Yy]* ]] && echo "✓ Development tools"
    [[ "$install_data" == [Yy]* ]] && echo "✓ Data science tools"
    [[ "$install_db" == [Yy]* ]] && echo "✓ Databases"
    [[ "$install_apps" == [Yy]* ]] && echo "✓ Desktop applications"
    [[ "$install_comm" == [Yy]* ]] && echo "✓ Communication tools"
    [[ "$install_api" == [Yy]* ]] && echo "✓ API development tools"
    [[ "$install_custom" == [Yy]* ]] && echo "✓ System customizations"
    [[ "$install_terminal" == [Yy]* ]] && echo "✓ Terminal tools"
    [[ "$install_security" == [Yy]* ]] && echo "✓ Security tools"
    [[ "$install_vm" == [Yy]* ]] && echo "✓ Virtualization tools"

    read -p "Proceed with these selections? (Y/n): " proceed
    proceed=${proceed:-y}

    if [[ "$proceed" != [Yy]* ]]; then
        print_message "red" "Installation aborted by user"
        if type log_message &>/dev/null; then log_message "INFO" "Installation aborted by user"; fi
        exit 0
    fi

    # Set global variables for use later
    export INSTALL_DEV_TOOLS=${install_dev}
    export INSTALL_DATA_TOOLS=${install_data}
    export INSTALL_DATABASES=${install_db}
    export INSTALL_DESKTOP_APPS=${install_apps}
    export INSTALL_COMM_APPS=${install_comm}
    export INSTALL_API_TOOLS=${install_api}
    export INSTALL_CUSTOMIZATIONS=${install_custom}
    export INSTALL_TERMINAL_TOOLS=${install_terminal}
    export INSTALL_SECURITY_TOOLS=${install_security}
    export INSTALL_VM_TOOLS=${install_vm}
}

# Function to install a component using its dedicated script (Uses idempotence.sh functions)
install_component() {
    local component=$1
    local script_path="$SCRIPT_DIR/install/$component.sh"

    if [ -f "$script_path" ]; then
        print_message "blue" "===== INSTALLING $component ====="
        if type log_message &>/dev/null; then log_message "INFO" "Starting installation of component: $component"; fi

        # Verificar si el componente ya está instalado usando el sistema de idempotencia
        if type is_component_installed &>/dev/null && is_component_installed "$component"; then
            print_message "yellow" "Component $component is already installed, skipping"
            if type log_message &>/dev/null; then log_message "INFO" "Component $component is already installed, skipping"; fi
            return 0
        fi

        # Ejecutar el script de instalación
        bash "$script_path"
        # check_success is now sourced from common.sh
        check_success "Installation of $component"

        # Marcar el componente como instalado si el sistema de idempotencia está disponible
        if type mark_component_installed &>/dev/null; then
            mark_component_installed "$component"
            if type log_message &>/dev/null; then log_message "INFO" "Component $component marked as installed"; fi
        else
             if type log_message &>/dev/null; then log_message "WARNING" "mark_component_installed function not available."; fi
        fi
    else
        print_message "yellow" "Installation script for $component not found: $script_path"
        if type log_message &>/dev/null; then log_message "WARNING" "Installation script not found: $script_path"; fi
        return 1
    fi

    return 0
}

# Check if running as root (which we don't want for most operations)
if [ "$(id -u)" -eq 0 ]; then
    print_message "red" "This script should not be run as root. Please run it as a regular user with sudo privileges."
    if type log_message &>/dev/null; then log_message "ERROR" "Script executed as root. Aborting."; fi
    exit 1
fi

# Initialize setup - create temporary directory (Uses ensure_dir from common.sh)
ensure_dir "$TEMP_DIR"
ensure_dir "$FONTS_DIR"

# Welcome message with ASCII art (Uses show_welcome_banner from banner.sh)
clear
if type show_welcome_banner &>/dev/null; then
    show_welcome_banner
else
    # Fallback ASCII art
    cat << 'EOF'
        ___   __  ___   __    _  _______  ______   _______  __   __
        |  |_|  ||   | |  |  | ||       ||      | |       ||  | |  |
        |       ||   | |   |_| ||_     _||  _    ||    ___||  |_|  |
        |       ||   | |       |  |   |  | | |   ||   |___ |       |
        |       ||   | |  _    |  |   |  | |_|   ||    ___||       |
        | ||_|| ||   | |   | |   |  |   |  |       ||   |___  |     |
        |_|   |_||___| |_|  |__|  |___|  |______| |_______|  |___|

        ________  _______  _______  __   __  _______
        |       ||       ||       ||  | |  ||       |
        |  _____||    ___||_     _||  | |  ||    _  |
        | |_____ |   |___   |   |  |  |_|  ||   |_| |
        |_____  ||    ___|  |   |  |       ||    ___|
        ______| ||   |___   |   |  |       ||   |
        |_______||_______|  |___|  |_______||___|
EOF
fi

print_message "blue" "======================================================"
print_message "blue" "     Linux Mint Cinnamon 22.1 Developer Setup"
print_message "blue" "======================================================"
print_message "yellow" "Este script instalará y configurará un entorno de desarrollo completo."
print_message "yellow" "You may be prompted for your password multiple times."
print_message "yellow" "Press CTRL+C at any time to cancel."
print_message "blue" "======================================================"
echo ""
read -p "Press ENTER to continue..."

# Check environment compatibility (Uses functions defined locally and calls common.sh functions)
check_environment

# Let user select visual theme (Uses functions from theme-manager.sh or fallback)
select_theme

# Show interactive menu for component selection
show_interactive_menu

# Update package lists and upgrade system
print_message "blue" "===== UPDATING SYSTEM PACKAGES ====="
if type log_message &>/dev/null; then log_message "INFO" "Updating system packages"; fi
sudo apt update && sudo apt upgrade -y
# check_success is now sourced from common.sh
check_success "System update and upgrade"

# Install essential system tools
print_message "blue" "===== INSTALLING SYSTEM UTILITIES ====="
if type log_message &>/dev/null; then log_message "INFO" "Installing essential system utilities"; fi
# install_package_if_needed from common.sh could be used here, but direct apt install is also fine for essentials
sudo apt install -y \
    curl wget git zsh unzip zip \
    build-essential software-properties-common \
    bat fzf ripgrep fd-find htop btop zoxide neofetch \
    fonts-firacode gnome-keyring dconf-cli apt-transport-https \
    bc conky-all fonts-noto fonts-noto-color-emoji fonts-jetbrains-mono
# check_success is now sourced from common.sh
check_success "System utilities installation"

# Install additional fonts
print_message "blue" "===== INSTALLING ADDITIONAL FONTS ====="
if type log_message &>/dev/null; then log_message "INFO" "Installing additional fonts"; fi
# Download and install JetBrains Mono Nerd Font
ensure_dir "$FONTS_DIR" # ensure_dir is now sourced from common.sh
cd "$FONTS_DIR"
print_message "yellow" "Downloading JetBrains Mono Nerd Font..."

# Usar secure_download si está disponible (Assuming secure_download is in security.sh)
if type secure_download &>/dev/null; then
    secure_download "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/Ligatures/Regular/complete/JetBrains%20Mono%20Regular%20Nerd%20Font%20Complete.ttf" "$FONTS_DIR/JetBrains Mono Regular Nerd Font Complete.ttf"
    secure_download "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/Ligatures/Bold/complete/JetBrains%20Mono%20Bold%20Nerd%20Font%20Complete.ttf" "$FONTS_DIR/JetBrains Mono Bold Nerd Font Complete.ttf"
    secure_download "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/Ligatures/Italic/complete/JetBrains%20Mono%20Italic%20Nerd%20Font%20Complete.ttf" "$FONTS_DIR/JetBrains Mono Italic Nerd Font Complete.ttf"
else
    # Fallback download method if secure_download is not available
    print_message "yellow" "Secure download function not available, using curl (ensure curl is installed)..."
    if type log_message &>/dev/null; then log_message "WARNING" "secure_download function not available, using curl."; fi
    curl -fLo "JetBrains Mono Regular Nerd Font Complete.ttf" \
    "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/Ligatures/Regular/complete/JetBrains%20Mono%20Regular%20Nerd%20Font%20Complete.ttf"
    curl -fLo "JetBrains Mono Bold Nerd Font Complete.ttf" \
    "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/Ligatures/Bold/complete/JetBrains%20Mono%20Bold%20Nerd%20Font%20Complete.ttf"
    curl -fLo "JetBrains Mono Italic Nerd Font Complete.ttf" \
    "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/Ligatures/Italic/complete/JetBrains%20Mono%20Italic%20Nerd%20Font%20Complete.ttf"
fi

fc-cache -fv
# check_success is now sourced from common.sh
check_success "Font installation"

# Configure system fonts
print_message "blue" "===== CONFIGURING SYSTEM FONTS ====="
if type log_message &>/dev/null; then log_message "INFO" "Configuring system fonts"; fi
gsettings set org.cinnamon.desktop.interface font-name 'Noto Sans 10'
gsettings set org.cinnamon.desktop.interface document-font-name 'Noto Sans 10'
gsettings set org.cinnamon.desktop.interface monospace-font-name 'JetBrains Mono Nerd Font 10'
gsettings set org.cinnamon.desktop.wm.preferences titlebar-font 'Noto Sans Bold 10'
# check_success is now sourced from common.sh
check_success "System font configuration"

# Configure terminal and shell
print_message "blue" "===== CONFIGURING SHELL ENVIRONMENT ====="
if type log_message &>/dev/null; then log_message "INFO" "Configuring shell environment"; fi

# Set up bat and fd aliases for zsh (we'll create these even if not using zsh yet)
if [ ! -f ~/.aliases ]; then
    echo "# Custom aliases for MintDev Setup" > ~/.aliases
    echo "alias cat='batcat'" >> ~/.aliases
    echo "alias fd='fdfind'" >> ~/.aliases
    echo "alias ls='ls --color=auto'" >> ~/.aliases
    echo "alias ll='ls -lahF'" >> ~/.aliases
    echo "alias update='sudo apt update && sudo apt upgrade'" >> ~/.aliases
    echo "alias install='sudo apt install'" >> ~/.aliases
    echo "alias remove='sudo apt remove'" >> ~/.aliases

    # Source aliases in both bash and zsh configs
    # Check if the line already exists before adding
    if ! grep -q "source ~/.aliases" ~/.bashrc; then
        echo "[ -f ~/.aliases ] && source ~/.aliases" >> ~/.bashrc
    fi

    # Ensure .zshrc exists before adding to it
    if [ ! -f ~/.zshrc ]; then
        touch ~/.zshrc
    fi
     if ! grep -q "source ~/.aliases" ~/.zshrc; then
        echo "[ -f ~/.aliases ] && source ~/.zshrc" >> ~/.zshrc
    fi
fi
# check_success is now sourced from common.sh
check_success "Shell aliases and configuration"


# Install components based on user selection (Uses install_component)
# Terminal tools
if [[ "$INSTALL_TERMINAL_TOOLS" == [Yy]* ]]; then
    install_component "zsh"
    install_component "alacritty"
    install_component "tmux"
    install_component "starship"
    install_component "micro"
    install_component "bat"
    install_component "ranger"
    install_component "neofetch" # Moved neofetch installation here
fi

# Development tools
if [[ "$INSTALL_DEV_TOOLS" == [Yy]* ]]; then
    install_component "python"
    install_component "nodejs"
    install_component "docker"
    install_component "github-cli"

    # Install Rust if not already installed for Zellij (Uses command_exists from common.sh)
    if ! command_exists cargo; then
        print_message "blue" "===== INSTALLING RUST ====="
        if type log_message &>/dev/null; then log_message "INFO" "Installing Rust"; fi

        # Use secure_download if available (Assuming secure_download is in security.sh)
        if type secure_download &>/dev/null; then
            secure_download "https://sh.rustup.rs" "$TEMP_DIR/rustup.sh"
            chmod +x "$TEMP_DIR/rustup.sh"
            "$TEMP_DIR/rustup.sh" -y
        else
            # Fallback download + execution
            print_message "yellow" "Secure download function not available, using curl for Rustup..."
            if type log_message &>/dev/null; then log_message "WARNING" "secure_download function not available for Rustup, using curl."; fi
            curl https://sh.rustup.rs -sSf | sh -s -- -y
        fi

        source "$HOME/.cargo/env"
        # check_success is now sourced from common.sh
        check_success "Rust installation"
    else
        print_message "yellow" "Rust is already installed"
        if type log_message &>/dev/null; then log_message "INFO" "Rust is already installed, skipping."; fi
    fi

    # Install Zellij terminal multiplexer (Uses command_exists, ensure_dir, check_success)
    if ! command_exists zellij; then
        print_message "blue" "===== INSTALLING ZELLIJ ====="
        if type log_message &>/dev/null; then log_message "INFO" "Installing Zellij"; fi
        # Assumes cargo is in PATH after Rust installation
        if command_exists cargo; then
            cargo install --locked zellij
            check_success "Zellij installation"

            # Configure Zellij
            ensure_dir "$CONFIG_DIR/zellij"
            # Copy configuration from local configs if available
            if [ -f "$SCRIPT_DIR/configs/zellij/config.kdl" ]; then
                cp "$SCRIPT_DIR/configs/zellij/config.kdl" "$CONFIG_DIR/zellij/config.kdl"
            else
                # Create default Zellij configuration
                cat > "$CONFIG_DIR/zellij/config.kdl" << 'EOF'
theme "tokyo-night"
default_layout "compact"
on_force_close "quit"

default_mode "locked"
keybinds clear-defaults=true {
    locked {
        bind "Ctrl g" { SwitchToMode "normal"; }
    }
    pane {
        bind "h" { MoveFocus "left"; }
        bind "j" { MoveFocus "down"; }
        bind "k" { MoveFocus "up"; }
        bind "l" { MoveFocus "right"; }
        bind "n" { NewPane; SwitchToMode "locked"; }
        bind "r" { NewPane "right"; SwitchToMode "locked"; }
        bind "d" { NewPane "down"; SwitchToMode "locked"; }
        bind "x" { CloseFocus; SwitchToMode "locked"; }
        bind "f" { ToggleFocusFullscreen; SwitchToMode "locked"; }
        bind "z" { TogglePaneFrames; SwitchToMode "locked"; }
        bind "p" { SwitchToMode "normal"; }
    }
    shared_among "normal" "locked" {
        bind "Alt h" { MoveFocusOrTab "left"; }
        bind "Alt j" { MoveFocus "down"; }
        bind "Alt k" { MoveFocus "up"; }
        bind "Alt l" { MoveFocusOrTab "right"; }
        bind "Alt n" { NewPane; }
    }
}
EOF
            fi
            check_success "Zellij configuration"
        else
            print_message "red" "Error: cargo command not found, cannot install Zellij."
            if type log_message &>/dev/null; then log_message "ERROR" "cargo command not found, cannot install Zellij."; fi
        fi
    else
        print_message "yellow" "Zellij is already installed"
        if type log_message &>/dev/null; then log_message "INFO" "Zellij is already installed, skipping."; fi
    fi
fi

# Data science tools
if [[ "$INSTALL_DATA_TOOLS" == [Yy]* ]]; then
    install_component "jupyter"
fi

# Databases
if [[ "$INSTALL_DATABASES" == [Yy]* ]]; then
    install_component "postgresql"
    install_component "mongodb"
fi

# Desktop applications
if [[ "$INSTALL_DESKTOP_APPS" == [Yy]* ]]; then
    install_component "vscode"
    install_component "libreoffice"
    install_component "spotify"
fi

# Communication tools
if [[ "$INSTALL_COMM_APPS" == [Yy]* ]]; then
    install_component "communication-apps"
fi

# API development tools
if [[ "$INSTALL_API_TOOLS" == [Yy]* ]]; then
    install_component "postman"
    # Check if Insomnia script exists before attempting to install
    if [ -f "$SCRIPT_DIR/install/insomnia.sh" ]; then
        install_component "insomnia"
    else
        print_message "yellow" "Insomnia installation script not found. Skipping."
        if type log_message &>/dev/null; then log_message "WARNING" "Insomnia installation script not found. Skipping."; fi
    fi
fi

# System customizations
if [[ "$INSTALL_CUSTOMIZATIONS" == [Yy]* ]]; then
    install_component "cinnamon-config"
    install_component "conky"
    install_component "plank"
    install_component "ulauncher"
    install_component "variety"
fi

# Security tools
if [[ "$INSTALL_SECURITY_TOOLS" == [Yy]* ]]; then
    # Install UFW (Uses check_success)
    print_message "blue" "===== INSTALLING UFW FIREWALL ====="
    if type log_message &>/dev/null; then log_message "INFO" "Installing UFW firewall"; fi
    # install_package_if_needed "ufw" # Could use the common function here
    sudo apt install -y ufw
    check_success "UFW installation"
    
    print_message "blue" "===== CONFIGURING UFW FIREWALL ====="
    if type log_message &>/dev/null; then log_message "INFO" "Configuring UFW firewall"; fi
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow ssh
    sudo ufw --force enable
    check_success "UFW configuration"

    # Install ClamAV (Uses check_success)
    print_message "blue" "===== INSTALLING CLAMAV ANTIVIRUS ====="
    if type log_message &>/dev/null; then log_message "INFO" "Installing ClamAV antivirus"; fi
    # install_package_if_needed "clamav clamav-daemon" # Could use the common function here
    sudo apt install -y clamav clamav-daemon
    check_success "ClamAV installation"
    
    print_message "blue" "===== CONFIGURING CLAMAV ANTIVIRUS ====="
    if type log_message &>/dev/null; then log_message "INFO" "Configuring ClamAV antivirus"; fi
    sudo systemctl enable clamav-freshclam
    sudo systemctl start clamav-freshclam
    check_success "ClamAV configuration"

    # Install fail2ban (Uses check_success)
    print_message "blue" "===== INSTALLING FAIL2BAN ====="
    if type log_message &>/dev/null; then log_message "INFO" "Installing fail2ban"; fi
    # install_package_if_needed "fail2ban" # Could use the common function here
    sudo apt install -y fail2ban
    check_success "fail2ban installation"

    print_message "blue" "===== CONFIGURING FAIL2BAN ====="
    if type log_message &>/dev/null; then log_message "INFO" "Configuring fail2ban"; fi
    sudo systemctl enable fail2ban
    sudo systemctl start fail2ban
    check_success "fail2ban configuration"
fi

# Virtualization tools
if [[ "$INSTALL_VM_TOOLS" == [Yy]* ]]; then
    # Install VirtualBox (Uses check_success)
    print_message "blue" "===== INSTALLING VIRTUALBOX ====="
    if type log_message &>/dev/null; then log_message "INFO" "Installing VirtualBox"; fi
    # install_package_if_needed "virtualbox virtualbox-ext-pack" # Could use the common function here
    sudo apt install -y virtualbox virtualbox-ext-pack
    check_success "VirtualBox installation"
    
    print_message "blue" "===== CONFIGURING VIRTUALBOX ====="
    if type log_message &>/dev/null; then log_message "INFO" "Configuring VirtualBox"; fi
    sudo usermod -aG vboxusers "$USER"
    check_success "VirtualBox configuration"

    # Install QEMU/KVM (Uses check_success)
    print_message "blue" "===== INSTALLING QEMU/KVM ====="
    if type log_message &>/dev/null; then log_message "INFO" "Installing QEMU/KVM"; fi
    # install_package_if_needed "qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager" # Could use the common function here
    sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager
    check_success "QEMU/KVM installation"
    
    print_message "blue" "===== CONFIGURING QEMU/KVM ====="
    if type log_message &>/dev/null; then log_message "INFO" "Configuring QEMU/KVM"; fi
    sudo usermod -aG libvirt "$USER"
    sudo usermod -aG kvm "$USER"
    check_success "QEMU/KVM configuration"
    print_message "yellow" "NOTE: You'll need to log out and back in for the group memberships to take effect"
    if type log_message &>/dev/null; then log_message "INFO" "QEMU/KVM group memberships note."; fi
fi


# Configure Cinnamon desktop shortcuts (Specific to Cinnamon, stays in main script)
print_message "blue" "===== CONFIGURING CINNAMON DESKTOP ENVIRONMENT ====="
if type log_message &>/dev/null; then log_message "INFO" "Configuring Cinnamon desktop environment"; fi
# These settings are specific to Linux Mint Cinnamon
gsettings set org.cinnamon.desktop.keybindings.wm move-to-workspace-left "['<Super>Shift+Left']"
gsettings set org.cinnamon.desktop.keybindings.wm move-to-workspace-right "['<Super>Shift+Right']"
gsettings set org.cinnamon.desktop.keybindings.wm switch-to-workspace-left "['<Super>Left']"
gsettings set org.cinnamon.desktop.keybindings.wm switch-to-workspace-right "['<Super>Right']"
gsettings set org.cinnamon.desktop.wm.preferences toggle-maximized "['<Super>Up']"
gsettings set org.cinnamon.desktop.wm.preferences minimize "['<Super>Down']"
gsettings set org.cinnamon.desktop.keybindings.wm close "['<Super>Q']"

# Configure Alt+Tab with CoverFlow effect
gsettings set org.cinnamon alttab-switcher-style 'coverflow'
gsettings set org.cinnamon alttab-minimized-aware true
gsettings set org.cinnamon alttab-switcher-delay 100

# Configure Flameshot for Print Screen
gsettings set org.cinnamon.desktop.keybindings.media-keys screenshot "['']"
gsettings set org.cinnamon.desktop.keybindings custom-list "['custom0']"
gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom0/ name "Flameshot"
gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom0/ command "flameshot gui"
gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom0/ binding "Print"

# Configure Cinnamon Panel
print_message "blue" "===== CONFIGURING CINNAMON PANEL ====="
if type log_message &>/dev/null; then log_message "INFO" "Configuring Cinnamon panel"; fi
# Configure panel in the bottom
gsettings set org.cinnamon panels-enabled "['1:0:bottom']"
# Configure panel applets
gsettings set org.cinnamon enabled-applets "['panel1:left:0:menu@cinnamon.org', 'panel1:left:1:show-desktop@cinnamon.org', 'panel1:left:2:grouped-window-list@cinnamon.org', 'panel1:right:0:systray@cinnamon.org', 'panel1:right:1:xapp-status@cinnamon.org', 'panel1:right:2:notifications@cinnamon.org', 'panel1:right:3:printers@cinnamon.org', 'panel1:right:4:removable-drives@cinnamon.org', 'panel1:right:5:keyboard@cinnamon.org', 'panel1:right:6:bluetooth@cinnamon.org', 'panel1:right:7:network@cinnamon.org', 'panel1:right:8:sound@cinnamon.org', 'panel1:right:9:power@cinnamon.org', 'panel1:right:10:calendar@cinnamon.org']"
# check_success is now sourced from common.sh
check_success "Cinnamon desktop configuration"

# Configure Cinnamon appearance (based on theme)
print_message "blue" "===== CONFIGURING DESKTOP APPEARANCE ====="
if type log_message &>/dev/null; then log_message "INFO" "Configuring desktop appearance with theme: $THEME_NAME"; fi

# Set dark theme
gsettings set org.cinnamon.desktop.interface gtk-theme "Mint-Y-Dark"
gsettings set org.cinnamon.desktop.wm.preferences theme "Mint-Y-Dark"
gsettings set org.cinnamon.theme name "Mint-Y-Dark"
gsettings set org.cinnamon.desktop.interface icon-theme "Mint-Y"
gsettings set org.cinnamon.desktop.interface cursor-theme "DMZ-Black"

# Configure terminal preferences
gsettings set org.gnome.Terminal.Legacy.Settings default-show-menubar false
gsettings set org.cinnamon.desktop.default-applications.terminal exec 'alacritty'
# check_success is now sourced from common.sh
check_success "Desktop appearance and terminal preferences configuration"


# Final message
print_message "blue" "======================================================"
print_message "green" "✓ SETUP COMPLETE!"
print_message "blue" "======================================================"
print_message "yellow" "You should log out and log back in to apply all changes."
print_message "yellow" "To switch to Zsh (if not already done), run: chsh -s $(which zsh)"
print_message "yellow" "Remember to set up your Git identity with:"
print_message "yellow" "  git config --global user.name \"Your Name\""
print_message "yellow" "  git config --global user.email \"your.email@example.com\""
print_message "blue" "======================================================"
print_message "cyan" "This script was inspired by the Omakub project (https://omakub.org)."
print_message "cyan" "Visit https://github.com/basecamp/omakub for the original project."
print_message "blue" "======================================================"

# Clean up (Uses ensure_dir - implicitly for parent of TEMP_DIR)
rm -rf "$TEMP_DIR"
print_message "green" "Temporary files cleaned up. Installation complete!"
if type log_message &>/dev/null; then log_message "INFO" "Temporary files cleaned up. Installation complete!"; fi


# Actualizar fecha de última actualización si la función está disponible (Assumes update_last_update is in idempotence.sh)
if type update_last_update &>/dev/null; then
    update_last_update
    if type log_message &>/dev/null; then log_message "INFO" "Last update timestamp updated."; fi
else
    if type log_message &>/dev/null; then log_message "WARNING" "update_last_update function not available."; fi
fi

# End of script
# Note: Added checks before calling functions from sourced files (e.g., type function_name &>/dev/null)
# This makes the fallback logic more robust if modules are missing.