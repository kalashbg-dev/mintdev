#!/bin/bash

# Gestor de temas para MintDev Setup
# Permite aplicar temas a diferentes componentes del sistema

# Archivo de índice de temas
THEMES_INDEX="$SCRIPT_DIR/themes/index.json"

# Función auxiliar para verificar si un comando existe
command_exists() {
    command -v "$1" &> /dev/null
}

# --- Dependency Check ---
# Function to check and install jq
check_and_install_jq() {
    if command_exists jq; then
        log_message "INFO" "'jq' ya está instalado."
        print_message "green" "'jq' dependency satisfied." # Mensaje amigable
        return 0 # jq is already installed
    fi

    log_message "WARNING" "'jq' not found. Attempting to install it..."
    print_message "yellow" "⚠️ 'jq' not found. Attempting to install 'jq' automatically..."

    # Check if running as root or if sudo is available
    if [[ $EUID -ne 0 ]]; then
        # Not root, check for sudo
        if command_exists sudo; then
            print_message "yellow" "Root privileges are needed to install 'jq'."
            print_message "yellow" "Please enter your password if prompted for 'sudo apt install jq'."
            # Attempt installation using sudo
            if sudo apt update && sudo apt install -y jq; then
                log_message "INFO" "'jq' installed successfully using sudo."
                print_message "green" "✓ 'jq' installed successfully."
                # Verify installation
                if command_exists jq; then
                    return 0
                else
                    log_message "ERROR" "Installation of 'jq' seemed successful, but the command is still not found."
                    print_message "red" "Error: 'jq' installation failed or was not effective."
                    print_message "red" "Please try installing it manually: sudo apt update && sudo apt install jq"
                    return 1 # Installation failed
                fi
            else
                log_message "ERROR" "Failed to install 'jq' using sudo apt."
                print_message "red" "Error: Automatic installation of 'jq' failed."
                print_message "red" "Please try installing it manually: sudo apt update && sudo apt install jq"
                return 1 # Installation failed
            fi
        else
            # Not root and sudo not available
            log_message "ERROR" "'jq' not found and could not be installed automatically (not root/sudo)."
            print_message "red" "Error: 'jq' not found."
            print_message "red" "Please install 'jq' manually with your package manager and try again."
            # Note: You might need to adapt the install command for other distributions
            print_message "red" "Example (Debian/Ubuntu/Mint): sudo apt update && sudo apt install jq"
            return 1 # Cannot install
        fi
    else
        # Running as root
        print_message "yellow" "Running as root. Proceeding to install 'jq'..."
        # Attempt installation directly
        if apt update && apt install -y jq; then
            log_message "INFO" "'jq' installed successfully as root."
            print_message "green" "✓ 'jq' installed successfully."
            # Verify installation
            if command_exists jq; then
                return 0
            else
                log_message "ERROR" "Installation of 'jq' seemed successful, but the command is still not found (root)."
                print_message "red" "Error: 'jq' installation failed or was not effective."
                print_message "red" "Please try installing it manually: apt update && apt install jq"
                return 1 # Installation failed
            fi
        else
            log_message "ERROR" "Failed to install 'jq' as root with apt."
            print_message "red" "Error: Automatic installation of 'jq' failed."
            print_message "red" "Please try installing it manually with your package manager."
            print_message "red" "Example (Debian/Ubuntu/Mint): apt update && apt install jq"
            return 1 # Installation failed
        fi
    fi
}

# Call the check and install function.
# If this function returns non-zero, the script should exit.
if ! check_and_install_jq; then
    exit 1
fi

# --- Helper Functions (assuming these are defined elsewhere or need definition) ---
# If print_message, log_message, ensure_dir, backup_file, is_component_installed,
# and set_current_theme are not defined in this script or sourced files,
# you will need to define them. Example stubs:

# print_message() {
#     local color="$1"
#     local message="$2"
#     case "$color" in
#         "red")    echo -e "\e[31m$message\e[0m" ;;
#         "green")  echo -e "\e[32m$message\e[0m" ;;
#         "yellow") echo -e "\e[33m$message\e[0m" ;;
#         "blue")   echo -e "\e[34m$message\e[0m" ;;
#         *)        echo "$message" ;;
#     esac
# }

# log_message() {
#     local level="$1"
#     local message="$2"
#     echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" # Example simple logging
# }

# ensure_dir() {
#     local dir="$1"
#     mkdir -p "$dir"
# }

# backup_file() {
#     local file="$1"
#     cp "$file" "$file.bak_$(date +%Y%m%d_%H%M%S)"
# }

# is_component_installed() {
#     local component="$1"
#     # This is a placeholder. You need to implement logic to check if a component
#     # (like alacritty, starship, vscode, etc.) is actually installed.
#     # Example: command -v "$component" &> /dev/null
#     # Note: 'vscode' might need a different check, like 'code' command
#     case "$component" in
#         "alacritty") command -v alacritty &> /dev/null ;;
#         "starship") command -v starship &> /dev/null ;;
#         "vscode") command -v code &> /dev/null ;;
#         "tmux") command -v tmux &> /dev/null ;;
#         "conky") command -v conky &> /dev/null ;;
#         *) return 1 ;; # Unknown component
#     esac
# }

# set_current_theme() {
#     local theme_id="$1"
#     # This is a placeholder. You need to implement logic to store the currently
#     # applied theme ID, likely in a state file.
#     echo "$theme_id" > "$SCRIPT_DIR/current_theme.txt" # Example state file
# }


# Función para listar todos los temas disponibles
list_available_themes() {
    if [ ! -f "$THEMES_INDEX" ]; then
        log_message "ERROR" "Archivo de índice de temas no encontrado: $THEMES_INDEX"
        print_message "red" "Error: Archivo de índice de temas no encontrado"
        return 1
    fi

    local themes=$(jq -r '.themes[] | .id + " - " + .name + ": " + .description' "$THEMES_INDEX")
    echo "$themes"
}

# Función para obtener información de un tema específico
get_theme_info() {
    local theme_id=$1

    if [ ! -f "$THEMES_INDEX" ]; then
        log_message "ERROR" "Archivo de índice de temas no encontrado: $THEMES_INDEX"
        return 1
    fi

    local theme_info=$(jq -r --arg id "$theme_id" '.themes[] | select(.id == $id)' "$THEMES_INDEX")

    if [ -z "$theme_info" ]; then
        log_message "ERROR" "Tema no encontrado: $theme_id"
        return 1
    fi

    echo "$theme_info"
}

# Función para obtener un color específico de un tema
get_theme_color() {
    local theme_id=$1
    local color_name=$2

    local theme_info=$(get_theme_info "$theme_id")

    if [ $? -ne 0 ]; then
        return 1
    fi

    local color=$(echo "$theme_info" | jq -r --arg color "$color_name" '.colors[$color]')

    if [ "$color" = "null" ]; then
        log_message "ERROR" "Color no encontrado: $color_name en tema $theme_id"
        return 1
    fi

    echo "$color"
}

# Función para verificar si un tema es compatible con una aplicación
is_theme_compatible_with_app() {
    local theme_id=$1
    local app_id=$2

    local theme_info=$(get_theme_info "$theme_id")

    if [ $? -ne 0 ]; then
        return 1
    fi

    local compatible=$(echo "$theme_info" | jq -r --arg app "$app_id" '.compatible_apps | contains([$app])')

    if [ "$compatible" = "true" ]; then
        return 0
    else
        return 1
    fi
}

# Función para aplicar un tema a Alacritty
apply_theme_to_alacritty() {
    local theme_id=$1

    log_message "INFO" "Aplicando tema $theme_id a Alacritty"

    # Verificar compatibilidad
    if ! is_theme_compatible_with_app "$theme_id" "alacritty"; then
        log_message "WARNING" "El tema $theme_id no es compatible con Alacritty"
        print_message "yellow" "⚠️ El tema $theme_id no es compatible con Alacritty"
        return 1
    fi

    # Verificar si existe un archivo de configuración específico para el tema
    local theme_config="$SCRIPT_DIR/themes/$theme_id/alacritty.toml"
    local config_dir="$HOME/.config/alacritty"

    ensure_dir "$config_dir"

    if [ -f "$theme_config" ]; then
        # Usar configuración específica del tema
        cp "$theme_config" "$config_dir/alacritty.toml"
        log_message "INFO" "Configuración específica de tema aplicada a Alacritty"
    else
        # Generar configuración basada en colores del tema
        local bg_color=$(get_theme_color "$theme_id" "background")
        local fg_color=$(get_theme_color "$theme_id" "foreground")
        local primary_color=$(get_theme_color "$theme_id" "primary")
        local secondary_color=$(get_theme_color "$theme_id" "secondary")
        local accent1_color=$(get_theme_color "$theme_id" "accent1")
        local accent2_color=$(get_theme_color "$theme_id" "accent2")
        local accent3_color=$(get_theme_color "$theme_id" "accent3")

        # Crear archivo de configuración
        cat > "$config_dir/alacritty.toml" << EOF
[font]
normal = { family = "FiraCode Nerd Font", style = "Regular" }
bold = { family = "FiraCode Nerd Font", style = "Bold" }
italic = { family = "FiraCode Nerd Font", style = "Italic" }
bold_italic = { family = "FiraCode Nerd Font", style = "Bold Italic" }
size = 12.0

[window]
padding = { x = 10, y = 10 }
opacity = 0.95
decorations = "Full"
startup_mode = "Windowed"

[cursor]
style = { shape = "Block", blinking = "On" }
thickness = 0.15

[colors.primary]
background = "$bg_color"
foreground = "$fg_color"

[colors.cursor]
text = "$bg_color"
cursor = "$fg_color"

[colors.normal]
black = "#000000"
red = "$accent1_color"
green = "$accent2_color"
yellow = "$accent3_color"
blue = "$primary_color"
magenta = "$secondary_color"
cyan = "#00ffff"
white = "#ffffff"

[colors.bright]
black = "#808080"
red = "$accent1_color"
green = "$accent2_color"
yellow = "$accent3_color"
blue = "$primary_color"
magenta = "$secondary_color"
cyan = "#00ffff"
white = "#ffffff"
EOF
        log_message "INFO" "Configuración generada para Alacritty basada en colores del tema"
    fi

    print_message "green" "✓ Tema $theme_id aplicado a Alacritty"
    return 0
}

# Función para aplicar un tema a Starship
apply_theme_to_starship() {
    local theme_id=$1

    log_message "INFO" "Aplicando tema $theme_id a Starship"

    # Verificar compatibilidad
    if ! is_theme_compatible_with_app "$theme_id" "starship"; then
        log_message "WARNING" "El tema $theme_id no es compatible con Starship"
        print_message "yellow" "⚠️ El tema $theme_id no es compatible con Starship"
        return 1
    fi

    # Verificar si existe un archivo de configuración específico para el tema
    local theme_config="$SCRIPT_DIR/themes/$theme_id/starship.toml"
    local config_file="$HOME/.config/starship.toml"

    ensure_dir "$(dirname "$config_file")"

    if [ -f "$theme_config" ]; then
        # Usar configuración específica del tema
        cp "$theme_config" "$config_file"
        log_message "INFO" "Configuración específica de tema aplicada a Starship"
    else
        # Generar configuración basada en colores del tema
        local primary_color=$(get_theme_color "$theme_id" "primary")
        local secondary_color=$(get_theme_color "$theme_id" "secondary")
        local accent1_color=$(get_theme_color "$theme_id" "accent1")
        local accent2_color=$(get_theme_color "$theme_id" "accent2")

        # Crear archivo de configuración
        cat > "$config_file" << EOF
# Configuración de Starship con tema $theme_id

# Configuración general
add_newline = true
command_timeout = 750
format = """
\$username\$hostname\$directory\$git_branch\$git_status
\$python\$nodejs\$rust\$golang\$docker
\$time\$character"""

# Módulo tiempo
[time]
disabled = false
time_format = "%H:%M:%S"
format = "[\$time](\$style) "
style = "bold $primary_color"

# Módulo username
[username]
show_always = false
format = "[\$user](\$style)@"
style_user = "bold $primary_color"

# Módulo hostname
[hostname]
ssh_only = false
format = "[\$hostname](\$style) "
style = "bold $primary_color"

# Módulo directorio
[directory]
truncation_length = 3
truncate_to_repo = true
format = "[\$path](\$style)[\$read_only](\$read_only_style) "
style = "bold $secondary_color"
read_only = " 🔒"
read_only_style = "bold $accent1_color"

# Módulo Git
[git_branch]
format = "[\$symbol\$branch](\$style) "
symbol = " "
style = "bold $secondary_color"

[git_status]
format = '([\$all_status\$ahead_behind](\$style) )'
style = "bold $accent2_color"
ahead = "⇡ \${count}"
behind = "⇣ \${count}"
diverged = "⇕ \${ahead_count}⇣\${behind_count}"
conflicted = "=\${count}"
deleted = "✘\${count}"
modified = "!\${count}"
staged = "+\${count}"
renamed = "»\${count}"
untracked = "?\${count}"

# Módulos de lenguajes de programación
[python]
format = '[\${symbol}\${pyenv_prefix}(\${version} )(\$\$\$virtualenv\$\$ )](\$style)'
style = "bold $accent2_color"
symbol = " "

[nodejs]
format = "[\${symbol}\${version}](\$style) "
style = "bold $accent2_color"
symbol = "⬢ "

[rust]
format = "[\${symbol}\${version}](\$style) "
style = "bold $accent1_color"
symbol = "🦀 "

[golang]
format = "[\${symbol}\${version}](\$style) "
style = "bold $primary_color"
symbol = "go "

[docker_context]
format = "[\${symbol}\${context}](\$style) "
style = "bold $primary_color"
symbol = "🐳 "

# Módulo del carácter de prompt
[character]
success_symbol = "[❯](bold $accent2_color)"
error_symbol = "[❯](bold $accent1_color)"
vimcmd_symbol = "[❮](bold $accent2_color)"
EOF
        log_message "INFO" "Configuración generada para Starship basada en colores del tema"
    fi

    print_message "green" "✓ Tema $theme_id aplicado a Starship"
    return 0
}

# Función para aplicar un tema a VS Code
apply_theme_to_vscode() {
    local theme_id=$1

    log_message "INFO" "Aplicando tema $theme_id a VS Code"

    # Verificar compatibilidad
    if ! is_theme_compatible_with_app "$theme_id" "vscode"; then
        log_message "WARNING" "El tema $theme_id no es compatible con VS Code"
        print_message "yellow" "⚠️ El tema $theme_id no es compatible con VS Code"
        return 1
    fi

    # Mapeo de temas a extensiones de VS Code
    local vscode_theme=""
    case $theme_id in
        "tokyo-night")
            vscode_theme="Tokyo Night"
            # Instalar extensión si no está instalada
            if command -v code &> /dev/null && ! code --list-extensions | grep -q "enkia.tokyo-night"; then
                print_message "yellow" "Instalando extensión de VS Code 'enkia.tokyo-night'..."
                code --install-extension enkia.tokyo-night
            fi
            ;;
        "nord")
            vscode_theme="Nord"
            if command -v code &> /dev/null && ! code --list-extensions | grep -q "arcticicestudio.nord-visual-studio-code"; then
                print_message "yellow" "Instalando extensión de VS Code 'arcticicestudio.nord-visual-studio-code'..."
                code --install-extension arcticicestudio.nord-visual-studio-code
            fi
            ;;
        "gruvbox")
            vscode_theme="Gruvbox Dark Medium"
            if command -v code &> /dev/null && ! code --list-extensions | grep -q "jdinhlife.gruvbox"; then
                print_message "yellow" "Instalando extensión de VS Code 'jdinhlife.gruvbox'..."
                code --install-extension jdinhlife.gruvbox
            fi
            ;;
        "dracula")
            vscode_theme="Dracula"
            if command -v code &> /dev/null && ! code --list-extensions | grep -q "dracula-theme.theme-dracula"; then
                print_message "yellow" "Instalando extensión de VS Code 'dracula-theme.theme-dracula'..."
                code --install-extension dracula-theme.theme-dracula
            fi
            ;;
        "catppuccin")
            vscode_theme="Catppuccin Mocha"
            if command -v code &> /dev/null && ! code --list-extensions | grep -q "Catppuccin.catppuccin-vsc"; then
                print_message "yellow" "Instalando extensión de VS Code 'Catppuccin.catppuccin-vsc'..."
                code --install-extension Catppuccin.catppuccin-vsc
            fi
            ;;
        "everforest")
            vscode_theme="Everforest Dark"
            if command -v code &> /dev/null && ! code --list-extensions | grep -q "sainnhe.everforest"; then
                print_message "yellow" "Instalando extensión de VS Code 'sainnhe.everforest'..."
                code --install-extension sainnhe.everforest
            fi
            ;;
        "kanagawa")
            vscode_theme="Kanagawa"
            if command -v code &> /dev/null && ! code --list-extensions | grep -q "qufiwefefwoyn.kanagawa"; then
                print_message "yellow" "Instalando extensión de VS Code 'qufiwefefwoyn.kanagawa'..."
                code --install-extension qufiwefefwoyn.kanagawa
            fi
            ;;
        "rose-pine")
            vscode_theme="Rosé Pine"
            if command -v code &> /dev/null && ! code --list-extensions | grep -q "mvllow.rose-pine"; then
                print_message "yellow" "Instalando extensión de VS Code 'mvllow.rose-pine'..."
                code --install-extension mvllow.rose-pine
            fi
            ;;
        *)
            log_message "ERROR" "Tema no soportado para VS Code: $theme_id"
            print_message "red" "Error: Tema no soportado para VS Code: $theme_id"
            return 1
            ;;
    esac

    # Ensure 'code' command exists before proceeding with settings
    if ! command -v code &> /dev/null; then
        log_message "WARNING" "VS Code ('code' command) not found, cannot apply theme settings."
        print_message "yellow" "⚠️ VS Code no encontrado, no se puede aplicar la configuración del tema."
        return 1
    fi

    # Configurar VS Code settings.json
    local settings_dir="$HOME/.config/Code/User"
    local settings_file="$settings_dir/settings.json"

    ensure_dir "$settings_dir"

    # Si el archivo no existe, crearlo
    if [ ! -f "$settings_file" ]; then
        echo "{}" > "$settings_file"
    fi

    # Actualizar tema en settings.json
    local temp_file=$(mktemp)
    # Use jq to update the JSON file. Check if jq is available again just in case,
    # although check_jq at the start should handle the main case.
    if command -v jq &> /dev/null; then
        jq --arg theme "$vscode_theme" '.["workbench.colorTheme"] = $theme' "$settings_file" > "$temp_file"
        mv "$temp_file" "$settings_file"
        print_message "green" "✓ Tema $theme_id aplicado a VS Code settings.json"
    else
         log_message "ERROR" "jq is required to update VS Code settings, but it's not found."
         print_message "red" "Error: 'jq' es necesario para actualizar la configuración de VS Code."
         return 1 # Indicate failure if jq is somehow missing here
    fi


    print_message "green" "✓ Tema $theme_id aplicado a VS Code"
    return 0
}

# Función para aplicar un tema a Tmux
apply_theme_to_tmux() {
    local theme_id=$1

    log_message "INFO" "Aplicando tema $theme_id a Tmux"

    # Verificar compatibilidad
    if ! is_theme_compatible_with_app "$theme_id" "tmux"; then
        log_message "WARNING" "El tema $theme_id no es compatible con Tmux"
        print_message "yellow" "⚠️ El tema $theme_id no es compatible con Tmux"
        return 1
    fi

    # Verificar si existe un archivo de configuración específico para el tema
    local theme_config="$SCRIPT_DIR/themes/$theme_id/tmux.conf"
    local config_file="$HOME/.tmux.conf"

    # Hacer copia de seguridad del archivo existente
    if [ -f "$config_file" ]; then
        backup_file "$config_file"
    fi

    if [ -f "$theme_config" ]; then
        # Usar configuración específica del tema
        cp "$theme_config" "$config_file"
        log_message "INFO" "Configuración específica de tema aplicada a Tmux"
    else
        # Generar configuración basada en colores del tema
        local bg_color=$(get_theme_color "$theme_id" "background")
        local fg_color=$(get_theme_color "$theme_id" "foreground")
        local primary_color=$(get_theme_color "$theme_id" "primary")
        local secondary_color=$(get_theme_color "$theme_id" "secondary")
        local accent1_color=$(get_theme_color "$theme_id" "accent1")

        # Eliminar el # de los colores para tmux
        bg_color=${bg_color#\#}
        fg_color=${fg_color#\#}
        primary_color=${primary_color#\#}
        secondary_color=${secondary_color#\#}
        accent1_color=${accent1_color#\#}

        # Crear archivo de configuración
        cat > "$config_file" << EOF
# Configuración de Tmux con tema $theme_id

# Cambiar prefijo a Ctrl+a (más fácil de alcanzar que Ctrl+b)
unbind C-b
set-option -g prefix C-a
bind-key C-a send-prefix

# Iniciar numeración de ventanas desde 1 en lugar de 0
set -g base-index 1
setw -g pane-base-index 1

# Habilitar el modo ratón
set -g mouse on

# Configuración de terminal
set -g default-terminal "screen-256color"
set -ag terminal-overrides ",xterm-256color:RGB"

# Mejorar el tiempo de respuesta
set -sg escape-time 0

# Aumentar el historial de líneas
set -g history-limit 10000

# Atajos de teclado
bind-key | split-window -h -c "#{pane_current_path}"
bind-key - split-window -v -c "#{pane_current_path}"
bind-key r source-file ~/.tmux.conf \; display-message "~/.tmux.conf recargado"
bind -n M-h select-pane -L
bind -n M-j select-pane -D
bind -n M-k select-pane -U
bind -n M-l select-pane -R
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5

# Notificaciones
setw -g monitor-activity on
set -g visual-activity on

# Configuración de tema
set -g status-style "bg=#$bg_color,fg=#$fg_color"
set -g window-status-current-style "bg=#$secondary_color,fg=#$bg_color"
set -g window-status-style "bg=#$bg_color,fg=#$fg_color"
set -g pane-active-border-style "fg=#$primary_color"
set -g pane-border-style "fg=#$secondary_color"
set -g message-style "bg=#$primary_color,fg=#$bg_color"

# Lista de plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'tmux-plugins/tmux-yank'

# Configuración de plugins
set -g @continuum-restore 'on'
set -g @resurrect-capture-pane-contents 'on'

# Inicializar TMUX plugin manager (debe estar al final del archivo)
run '~/.tmux/plugins/tpm/tpm'
EOF
        log_message "INFO" "Configuración generada para Tmux basada en colores del tema"
    fi

    # Recargar configuración de tmux si está en ejecución
    if pgrep tmux &> /dev/null; then
        print_message "yellow" "Recargando configuración de Tmux..."
        tmux source-file "$config_file" 2>/dev/null || true
    fi

    print_message "green" "✓ Tema $theme_id aplicado a Tmux"
    return 0
}

# Función para aplicar un tema a Conky
apply_theme_to_conky() {
    local theme_id=$1

    log_message "INFO" "Aplicando tema $theme_id a Conky"

    # Verificar compatibilidad
    if ! is_theme_compatible_with_app "$theme_id" "conky"; then
        log_message "WARNING" "El tema $theme_id no es compatible con Conky"
        print_message "yellow" "⚠️ El tema $theme_id no es compatible con Conky"
        return 1
    fi

    # Verificar si existe un archivo de configuración específico para el tema
    local theme_config="$SCRIPT_DIR/configs/conky/$theme_id.conf"
    local config_dir="$HOME/.config/conky"
    local config_file="$config_dir/conky.conf"

    ensure_dir "$config_dir"

    if [ -f "$theme_config" ]; then
        # Usar configuración específica del tema
        cp "$theme_config" "$config_file"
        log_message "INFO" "Configuración específica de tema aplicada a Conky"
    else
        # Generar configuración basada en colores del tema
        local bg_color=$(get_theme_color "$theme_id" "background")
        local fg_color=$(get_theme_color "$theme_id" "foreground")
        local primary_color=$(get_theme_color "$theme_id" "primary")
        local accent1_color=$(get_theme_color "$theme_id" "accent1")
        local accent2_color=$(get_theme_color "$theme_id" "accent2")
        local accent3_color=$(get_theme_color "$theme_id" "accent3")

        # Crear archivo de configuración
        cat > "$config_file" << EOF
conky.config = {
    alignment = 'top_right',
    background = true,
    border_width = 1,
    cpu_avg_samples = 2,
    default_color = '$fg_color',
    color1 = '$primary_color',
    color2 = '$accent1_color',
    color3 = '$accent2_color',
    double_buffer = true,
    font = 'JetBrains Mono Nerd Font:size=10',
    gap_x = 25,
    gap_y = 50,
    minimum_width = 250,
    maximum_width = 250,
    no_buffers = true,
    own_window = true,
    own_window_class = 'Conky',
    own_window_type = 'desktop',
    own_window_transparent = false,
    own_window_argb_visual = true,
    own_window_argb_value = 180,
    own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',
    own_window_colour = '$bg_color',
    update_interval = 1.0,
    use_xft = true,
};

conky.text = [[
\${font JetBrains Mono Nerd Font:bold:size=12}\${color1}SISTEMA \${hr 2}\${font}
\${color}Kernel: \$kernel
Uptime: \$uptime
\${color1}CPU \${hr 2}\${color}
\${color}Uso: \${cpu}% \${color3}\${cpubar}
\${color}Temperatura: \${acpitemp}°C
\${color1}MEMORIA \${hr 2}\${color}
\${color}RAM: \$mem/\$memmax \${color3}\${membar}
\${color}Swap: \$swap/\$swapmax \${color3}\${swapbar}
\${color1}DISCO \${hr 2}\${color}
\${color}Root: \${fs_used /}/\${fs_size /} \${color3}\${fs_bar /}
\${color}I/O: \${diskio}
\${color1}RED \${hr 2}\${color}
\${color}Local IP: \${addr wlp3s0}
\${color}Subida: \${upspeed wlp3s0} \${color}Bajada: \${downspeed wlp3s0}
\${color1}PROCESOS \${hr 2}\${color}
\${color}Total: \$processes Ejecutándose: \$running_processes
\${color}\${top name 1} \${top pid 1} \${top cpu 1} \${top mem 1}
\${color}\${top name 2} \${top pid 2} \${top cpu 2} \${top mem 2}
\${color}\${top name 3} \${top pid 3} \${top cpu 3} \${top mem 3}
]]
EOF
        log_message "INFO" "Configuración generada para Conky basada en colores del tema"
    fi

    # Reiniciar Conky si está en ejecución
    if pgrep conky &> /dev/null; then
        print_message "yellow" "Reiniciando Conky..."
        killall conky
        sleep 1
        # Start conky detached and with the specific config file
        conky -c "$config_file" -d &
    fi

    print_message "green" "✓ Tema $theme_id aplicado a Conky"
    return 0
}

# Función para aplicar un tema a todo el sistema
apply_theme_system_wide() {
    local theme_id=$1

    log_message "INFO" "Aplicando tema $theme_id a todo el sistema"

    # Verificar si el tema existe
    if ! get_theme_info "$theme_id" &> /dev/null; then
        log_message "ERROR" "Tema no encontrado: $theme_id"
        print_message "red" "Error: Tema no encontrado: $theme_id"
        return 1
    fi

    print_message "blue" "Aplicando tema $theme_id a todo el sistema..."

    # Aplicar tema a cada componente compatible
    local components=("alacritty" "starship" "vscode" "tmux" "conky")
    local success_count=0
    local total_count=0

    for component in "${components[@]}"; do
        # Check if the theme is compatible with this component based on index.json
        if is_theme_compatible_with_app "$theme_id" "$component"; then
            ((total_count++))

            # Check if the component itself is installed
            if is_component_installed "$component"; then
                print_message "yellow" "Aplicando tema a $component..."

                # Apply theme to the component
                case $component in
                    "alacritty")
                        apply_theme_to_alacritty "$theme_id"
                        if [ $? -eq 0 ]; then ((success_count++)); fi
                        ;;
                    "starship")
                        apply_theme_to_starship "$theme_id"
                        if [ $? -eq 0 ]; then ((success_count++)); fi
                        ;;
                    "vscode")
                        apply_theme_to_vscode "$theme_id"
                        if [ $? -eq 0 ]; then ((success_count++)); fi
                        ;;
                    "tmux")
                        apply_theme_to_tmux "$theme_id"
                        if [ $? -eq 0 ]; then ((success_count++)); fi
                        ;;
                    "conky")
                        apply_theme_to_conky "$theme_id"
                        if [ $? -eq 0 ]; then ((success_count++)); fi
                        ;;
                esac
            else
                print_message "yellow" "Componente $component no instalado, omitiendo"
                log_message "INFO" "Componente $component no instalado, omitiendo aplicación de tema"
            fi
        else
             log_message "INFO" "Tema $theme_id no compatible con $component, omitiendo"
             # print_message "blue" "Tema no compatible con $component, omitiendo." # Optional: inform user about incompatibility
        fi
    done

    # Actualizar tema actual en el archivo de estado
    set_current_theme "$theme_id"

    print_message "blue" "Resumen de aplicación de tema:"
    print_message "blue" "- Total de componentes compatibles y encontrados: $total_count"
    print_message "green" "- Temas aplicados correctamente: $success_count"

    if [ $success_count -eq $total_count ]; then
        print_message "green" "✓ Tema $theme_id aplicado correctamente a todos los componentes compatibles instalados"
        return 0
    else
        print_message "yellow" "⚠️ Algunos componentes no pudieron recibir el tema correctamente o no están instalados."
        log_message "WARNING" "No se pudo aplicar el tema a todos los componentes compatibles instalados"
        return 1
    fi
}

# Función para mostrar una vista previa del tema
preview_theme() {
    local theme_id=$1

    log_message "INFO" "Mostrando vista previa del tema $theme_id"

    # Verificar si el tema existe
    local theme_info=$(get_theme_info "$theme_id")

    if [ $? -ne 0 ]; then
        print_message "red" "Error: Tema no encontrado: $theme_id"
        return 1
    fi

    # Mostrar información del tema
    local theme_name=$(echo "$theme_info" | jq -r '.name')
    local theme_desc=$(echo "$theme_info" | jq -r '.description')
    local theme_author=$(echo "$theme_info" | jq -r '.author')

    print_message "blue" "===== VISTA PREVIA DEL TEMA ====="
    print_message "blue" "Nombre: $theme_name"
    print_message "blue" "Descripción: $theme_desc"
    print_message "blue" "Autor: $theme_author"
    print_message "blue" "===== COLORES ====="

    # Mostrar colores del tema
    local bg_color=$(get_theme_color "$theme_id" "background")
    local fg_color=$(get_theme_color "$theme_id" "foreground")
    local primary_color=$(get_theme_color "$theme_id" "primary")
    local secondary_color=$(get_theme_color "$theme_id" "secondary")
    local accent1_color=$(get_theme_color "$theme_id" "accent1")
    local accent2_color=$(get_theme_color "$theme_id" "accent2")
    local accent3_color=$(get_theme_color "$theme_id" "accent3")

    # Ensure colors are not empty before trying to print
    if [ -n "$bg_color" ]; then echo -e "Fondo: \e[48;2;$(hex_to_rgb $bg_color);38;2;$(hex_to_rgb $fg_color)m$bg_color\e[0m"; fi
    if [ -n "$fg_color" ]; then echo -e "Texto: \e[38;2;$(hex_to_rgb $fg_color)m$fg_color\e[0m"; fi
    if [ -n "$primary_color" ]; then echo -e "Primario: \e[38;2;$(hex_to_rgb $primary_color)m$primary_color\e[0m"; fi
    if [ -n "$secondary_color" ]; then echo -e "Secundario: \e[38;2;$(hex_to_rgb $secondary_color)m$secondary_color\e[0m"; fi
    if [ -n "$accent1_color" ]; then echo -e "Acento 1: \e[38;2;$(hex_to_rgb $accent1_color)m$accent1_color\e[0m"; fi
    if [ -n "$accent2_color" ]; then echo -e "Acento 2: \e[38;2;$(hex_to_rgb $accent2_color)m$accent2_color\e[0m"; fi
    if [ -n "$accent3_color" ]; then echo -e "Acento 3: \e[38;2;$(hex_to_rgb $accent3_color)m$accent3_color\e[0m"; fi

    print_message "blue" "===== APLICACIONES COMPATIBLES ====="
    local compatible_apps=$(echo "$theme_info" | jq -r '.compatible_apps | join(", ")')
    if [ -n "$compatible_apps" ]; then
        echo "$compatible_apps"
    else
        echo "Ninguna aplicación compatible listada en el índice del tema."
    fi

    return 0
}

# Función auxiliar para convertir color hexadecimal a RGB

hex_to_rgb() {
    local hex="$1"
    # Remove # if present
    hex=${hex#\#}

    # Check if the hex string has the correct length (6 characters)
    if [ ${#hex} -ne 6 ]; then
        log_message "ERROR" "Invalid hex color format: $1"
        echo "0;0;0" # Return black as a default in case of error
        return 1
    fi

    # Convert hex pairs to decimal
    local r=$(printf '%d' 0x${hex:0:2})
    local g=$(printf '%d' 0x${hex:2:2})
    local b=$(printf '%d' 0x${hex:4:2})

    echo "$r;$g;$b"
}

# Note: This script assumes that SCRIPT_DIR, print_message, log_message,
# ensure_dir, backup_file, is_component_installed, and set_current_theme
# are defined elsewhere or sourced before this script is executed.
# I've included placeholder stubs for these functions in the corrected code block
# as comments, in case you need to define them. You should replace these stubs
# with your actual implementations if they are not provided by your setup framework.