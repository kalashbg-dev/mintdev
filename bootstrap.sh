set -e

REPO_GIT_URL="https://github.com/kalashbg-dev/mintdev.git" 

LOCAL_REPO_PATH="$HOME/.local/share/mint-dev-setup"

MAIN_SCRIPT="setup_mint_dev.sh"

bootstrap_message() {
    local color=$1
    local message=$2
    case $color in
        "green") echo -e "\e[32m[BOOTSTRAP] $message\e[0m" ;;
        "blue")  echo -e "\e[34m[BOOTSTRAP] $message\e[0m" ;;
        "yellow")echo -e "\e[33m[BOOTSTRAP] $message\e[0m" ;;
        "red")   echo -e "\e[31m[BOOTSTRAP] $message\e[0m" ;;
        *)       echo "[BOOTSTRAP] $message" ;;
    esac
}

clear

cat << 'EOF'
        ___   __  ___   __    _  _______  ______   _______  __   __
        |  |_|  ||   | |  |  | ||       ||      | |       ||  | |  |
        |       ||   | |   |_| ||_     _||  _    ||    ___||  |_|  |
        |       ||   | |       |  |   |  | | |   ||   |___ |       |
        |       ||   | |  __   |  |   |  | |_|   ||    ___||       |
        | ||_|| ||   | | |  |  |  |   |  |       ||   |___  |     |
        |_|   |_||___| |_|  |__|  |___|  |______| |_______|  |___|

        ________  _______  _______  __   __  _______
        |       ||       ||       ||  | |  ||       |
        |  _____||    ___||_     _||  | |  ||    _  |
        | |_____ |   |___   |   |  |  |_|  ||   |_| |
        |_____  ||    ___|  |   |  |       ||    ___|
        ______| ||   |___   |   |  |       ||   |
        |_______||_______|  |___|  |_______||___|
EOF

echo "" 
bootstrap_message "blue" "===== MintDev Setup Bootstrap ====="
bootstrap_message "yellow" "This script will prepare your system and execute the main configuration."
bootstrap_message "yellow" "You will need sudo privileges for package installations."
echo "" 
read -p "Presiona ENTER para continuar o CTRL+C para abortar..."

bootstrap_message "blue" "Checking for git and updating package lists..."
if ! command -v git &> /dev/null; then
    bootstrap_message "yellow" "git not found. Attempting to install git..."
    # Need sudo here. Assumes the user ran the initial command with sudo.
    if command -v sudo &> /dev/null; then
        # Add apt update before installing git, like Omakub
        bootstrap_message "yellow" "Updating package lists (apt update)..."
        if sudo apt update >/dev/null; then # Silenciar la salida verbosa de update
            bootstrap_message "green" "Package list updated."
            if sudo apt install -y git >/dev/null; then # Silenciar la salida verbosa de install
                bootstrap_message "green" "git installed successfully."
            else
                bootstrap_message "red" "Error installing git. Aborting."
                exit 1
            fi
        else
            bootstrap_message "red" "Error updating package lists (apt update). Cannot install git. Aborting."
            exit 1
        fi
    else
        bootstrap_message "red" "Error: git not found and sudo is not available to install it. Aborting."
        exit 1
    fi
else
    bootstrap_message "green" "git is already installed."
fi

bootstrap_message "blue" "Cloning or updating repository into $LOCAL_REPO_PATH..."

if [ -d "$LOCAL_REPO_PATH" ]; then
    # Repository already exists, attempt to pull updates
    bootstrap_message "yellow" "Repository already exists. Attempting to pull updates."
    cd "$LOCAL_REPO_PATH" || { bootstrap_message "red" "Error: Could not change directory to $LOCAL_REPO_PATH. Aborting."; exit 1; }
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ -z "$CURRENT_BRANCH" ]; then
        bootstrap_message "yellow" "Warning: Could not determine current branch. Attempting 'git pull' anyway."
        git pull
    else
        bootstrap_message "yellow" "Pulling updates for branch: $CURRENT_BRANCH"
        git pull origin "$CURRENT_BRANCH"
    fi

    if [ $? -eq 0 ]; then
        bootstrap_message "green" "Repository updated successfully."
    else
        bootstrap_message "yellow" "Warning: Could not pull updates for the repository."
        bootstrap_message "yellow" "Proceeding with the existing local copy."
    fi

    cd - >/dev/null
else
    bootstrap_message "blue" "Cloning repository from $REPO_GIT_URL..."
    mkdir -p "$(dirname "$LOCAL_REPO_PATH")"
    if git clone "$REPO_GIT_URL" "$LOCAL_REPO_PATH"; then
        bootstrap_message "green" "Repository cloned successfully."
    else
        bootstrap_message "red" "Error cloning repository. Aborting."
        exit 1
    fi
fi

bootstrap_message "blue" "Executing main setup script: $LOCAL_REPO_PATH/$MAIN_SCRIPT..."

if [ ! -f "$LOCAL_REPO_PATH/$MAIN_SCRIPT" ]; then
    bootstrap_message "red" "Error: Main script '$MAIN_SCRIPT' not found in the cloned repository."
    bootstrap_message "red" "Verify the REPO_GIT_URL and MAIN_SCRIPT name."
    exit 1
fi

cd "$LOCAL_REPO_PATH" || {
    bootstrap_message "red" "Error: Could not change directory to $LOCAL_REPO_PATH."
    exit 1
}

bootstrap_message "yellow" "Starting the main setup process from cloned repository..."
exec bash "./$MAIN_SCRIPT"

# --- End of Bootstrap ---
