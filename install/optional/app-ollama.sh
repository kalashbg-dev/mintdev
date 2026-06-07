#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../../lib/common.sh"

print_message "blue" "===== INSTALLING OLLAMA ====="
if ! command -v ollama &> /dev/null; then
    curl -fsSL https://ollama.com/install.sh | sh
    check_success "Ollama installation"
else
    print_message "yellow" "Ollama is already installed"
fi
