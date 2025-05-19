#!/bin/bash

# Script de instalación para Zsh y Oh My Zsh en Linux Mint

# Obtener directorio del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../lib/common.sh"

print_message "blue" "===== INSTALANDO Y CONFIGURANDO ZSH ====="
if ! is_installed zsh; then
    sudo apt install -y zsh
    check_success "Instalación de Zsh"
else
    print_message "yellow" "Zsh ya está instalado"
fi

# Instalar Oh My Zsh si no está instalado
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    print_message "yellow" "Instalando Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    check_success "Instalación de Oh My Zsh"
else
    print_message "yellow" "Oh My Zsh ya está instalado"
fi

# Instalar plugins populares
print_message "yellow" "Instalando plugins para Zsh..."

# Plugin zsh-autosuggestions
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

# Plugin zsh-syntax-highlighting
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

# Instalar powerlevel10k
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
fi

# Configurar Zsh según el tema seleccionado
print_message "yellow" "Configurando Zsh para el tema $THEME_NAME..."

# Hacer copia de seguridad del archivo .zshrc existente
backup_file "$HOME/.zshrc"

# Crear nuevo archivo .zshrc
cat > "$HOME/.zshrc" << EOF
# Configuración de Zsh generada por omakub-mint-version
# Tema actual: $THEME_NAME

# Ruta a Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"

# Tema Powerlevel10k
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  docker
  composer
  npm
  python
  pip
  vscode
  command-not-found
  sudo
  web-search
  history
  zoxide
)

# Cargar Oh My Zsh
source \$ZSH/oh-my-zsh.sh

# Configuraciones adicionales
export EDITOR='nano'
export VISUAL='code'
export PAGER='less'

# Alias útiles
alias zshconfig="code ~/.zshrc"
alias ohmyzsh="code ~/.oh-my-zsh"
alias update="sudo apt update && sudo apt upgrade -y"
alias install="sudo apt install"
alias remove="sudo apt remove"
alias purge="sudo apt purge"
alias search="apt search"
alias ls="ls --color=auto"
alias ll="ls -la"
alias la="ls -A"
alias l="ls -CF"
alias cls="clear"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias md="mkdir -p"
alias rd="rmdir"
alias df="df -h"
alias du="du -h"
alias free="free -h"

# Configurar Zoxide (navegación inteligente de directorios)
eval "\$(zoxide init zsh)"

# NVM (Node Version Manager)
export NVM_DIR="\$HOME/.nvm"
[ -s "\$NVM_DIR/nvm.sh" ] && \. "\$NVM_DIR/nvm.sh"
[ -s "\$NVM_DIR/bash_completion" ] && \. "\$NVM_DIR/bash_completion"

# Personalización de colores según el tema
EOF

# Añadir configuraciones específicas según el tema
case $THEME_NAME in
    "tokyo-night")
        cat >> "$HOME/.zshrc" << EOF
# Colores Tokyo Night
POWERLEVEL9K_COLOR_SCHEME='dark'
POWERLEVEL9K_BACKGROUND='236'
POWERLEVEL9K_FOREGROUND='59'
POWERLEVEL9K_TIME_BACKGROUND='67'
POWERLEVEL9K_TIME_FOREGROUND='195'
POWERLEVEL9K_DIR_HOME_BACKGROUND='67'
POWERLEVEL9K_DIR_HOME_FOREGROUND='195'
POWERLEVEL9K_DIR_HOME_SUBFOLDER_BACKGROUND='67'
POWERLEVEL9K_DIR_HOME_SUBFOLDER_FOREGROUND='195'
POWERLEVEL9K_DIR_DEFAULT_BACKGROUND='67'
POWERLEVEL9K_DIR_DEFAULT_FOREGROUND='195'

# Configuración de Powerlevel10k Tokyo Night
POWERLEVEL9K_MODE='nerdfont-complete'
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status time)
EOF
        ;;
    "catppuccin")
        cat >> "$HOME/.zshrc" << EOF
# Colores Catppuccin
POWERLEVEL9K_COLOR_SCHEME='dark'
POWERLEVEL9K_BACKGROUND='236'
POWERLEVEL9K_FOREGROUND='183'
POWERLEVEL9K_TIME_BACKGROUND='141'
POWERLEVEL9K_TIME_FOREGROUND='236'
POWERLEVEL9K_DIR_HOME_BACKGROUND='141'
POWERLEVEL9K_DIR_HOME_FOREGROUND='236'
POWERLEVEL9K_DIR_HOME_SUBFOLDER_BACKGROUND='141'
POWERLEVEL9K_DIR_HOME_SUBFOLDER_FOREGROUND='236'
POWERLEVEL9K_DIR_DEFAULT_BACKGROUND='141'
POWERLEVEL9K_DIR_DEFAULT_FOREGROUND='236'

# Configuración de Powerlevel10k Catppuccin
POWERLEVEL9K_MODE='nerdfont-complete'
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status time)
EOF
        ;;
    "nord")
        cat >> "$HOME/.zshrc" << EOF
# Colores Nord
POWERLEVEL9K_COLOR_SCHEME='dark'
POWERLEVEL9K_BACKGROUND='236'
POWERLEVEL9K_FOREGROUND='153'
POWERLEVEL9K_TIME_BACKGROUND='110'
POWERLEVEL9K_TIME_FOREGROUND='236'
POWERLEVEL9K_DIR_HOME_BACKGROUND='110'
POWERLEVEL9K_DIR_HOME_FOREGROUND='236'
POWERLEVEL9K_DIR_HOME_SUBFOLDER_BACKGROUND='110'
POWERLEVEL9K_DIR_HOME_SUBFOLDER_FOREGROUND='236'
POWERLEVEL9K_DIR_DEFAULT_BACKGROUND='110'
POWERLEVEL9K_DIR_DEFAULT_FOREGROUND='236'

# Configuración de Powerlevel10k Nord
POWERLEVEL9K_MODE='nerdfont-complete'
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status time)
EOF
        ;;
    "gruvbox")
        cat >> "$HOME/.zshrc" << EOF
# Colores Gruvbox
POWERLEVEL9K_COLOR_SCHEME='dark'
POWERLEVEL9K_BACKGROUND='236'
POWERLEVEL9K_FOREGROUND='214'
POWERLEVEL9K_TIME_BACKGROUND='172'
POWERLEVEL9K_TIME_FOREGROUND='236'
POWERLEVEL9K_DIR_HOME_BACKGROUND='172'
POWERLEVEL9K_DIR_HOME_FOREGROUND='236'
POWERLEVEL9K_DIR_HOME_SUBFOLDER_BACKGROUND='172'
POWERLEVEL9K_DIR_HOME_SUBFOLDER_FOREGROUND='236'
POWERLEVEL9K_DIR_DEFAULT_BACKGROUND='172'
POWERLEVEL9K_DIR_DEFAULT_FOREGROUND='236'

# Configuración de Powerlevel10k Gruvbox
POWERLEVEL9K_MODE='nerdfont-complete'
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status time)
EOF
        ;;
    "dracula")
        cat >> "$HOME/.zshrc" << EOF
# Colores Dracula
POWERLEVEL9K_COLOR_SCHEME='dark'
POWERLEVEL9K_BACKGROUND='236'
POWERLEVEL9K_FOREGROUND='141'
POWERLEVEL9K_TIME_BACKGROUND='141'
POWERLEVEL9K_TIME_FOREGROUND='236'
POWERLEVEL9K_DIR_HOME_BACKGROUND='141'
POWERLEVEL9K_DIR_HOME_FOREGROUND='236'
POWERLEVEL9K_DIR_HOME_SUBFOLDER_BACKGROUND='141'
POWERLEVEL9K_DIR_HOME_SUBFOLDER_FOREGROUND='236'
POWERLEVEL9K_DIR_DEFAULT_BACKGROUND='141'
POWERLEVEL9K_DIR_DEFAULT_FOREGROUND='236'

# Configuración de Powerlevel10k Dracula
POWERLEVEL9K_MODE='nerdfont-complete'
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status time)
EOF
        ;;
    *)
        # Configuración predeterminada
        cat >> "$HOME/.zshrc" << EOF
# Configuración predeterminada de Powerlevel10k
POWERLEVEL9K_MODE='nerdfont-complete'
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status time)
EOF
        ;;
esac

# Añadir configuración para ejecutar neofetch al inicio
cat >> "$HOME/.zshrc" << EOF

# Ejecutar neofetch al iniciar terminal
neofetch
EOF

# Cambiar la shell predeterminada a Zsh
if [[ "$SHELL" != *"zsh"* ]]; then
    print_message "yellow" "Cambiando la shell predeterminada a Zsh..."
    chsh -s $(which zsh)
    check_success "Cambio de shell predeterminada"
    print_message "yellow" "Es posible que necesites cerrar sesión y volver a iniciarla para que el cambio tenga efecto."
fi

print_message "green" "✓ Zsh y Oh My Zsh instalados y configurados correctamente"
print_message "yellow" "Abre una nueva terminal para ver la nueva configuración"
print_message "yellow" "La primera vez que inicies Zsh, se te pedirá configurar Powerlevel10k. Sigue las instrucciones en pantalla."
