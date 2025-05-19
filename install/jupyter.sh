#!/bin/bash

# Script de instalación para Jupyter Notebook/Lab en Linux Mint
# Configura un entorno virtual dedicado para análisis de datos

# Obtener directorio del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../lib/common.sh"

print_message "blue" "===== INSTALANDO JUPYTER NOTEBOOK/LAB Y PAQUETES PARA ANÁLISIS DE DATOS ====="

# Verificar si Python está instalado
if ! command -v python3 &> /dev/null; then
    print_message "yellow" "Python 3 no está instalado, instalándolo primero..."
    sudo apt install -y python3 python3-pip python3-venv python3-dev
    check_success "Instalación de Python"
fi

# Crear un directorio para entornos virtuales si no existe
print_message "yellow" "Configurando entorno virtual de Python dedicado para análisis de datos..."
VENV_DIR="$HOME/.venvs"
ensure_dir "$VENV_DIR"

# Crear entorno virtual para análisis de datos
DATAVENV_NAME="data_analytics"
DATAVENV_PATH="$VENV_DIR/$DATAVENV_NAME"

if [ ! -d "$DATAVENV_PATH" ]; then
    print_message "yellow" "Creando entorno virtual '$DATAVENV_NAME'..."
    python3 -m venv "$DATAVENV_PATH"
    check_success "Creación del entorno virtual $DATAVENV_NAME"
else
    print_message "yellow" "El entorno virtual '$DATAVENV_NAME' ya existe"
fi

# Activar el entorno virtual e instalar paquetes
print_message "yellow" "Instalando Jupyter y paquetes para análisis de datos en el entorno virtual (esto puede tardar unos minutos)..."
source "$DATAVENV_PATH/bin/activate"

# Actualizar pip dentro del entorno virtual
pip install --upgrade pip

# Instalar Jupyter y sus extensiones
pip install jupyterlab notebook jupyterlab-git nbformat nbconvert voila ipywidgets
check_success "Instalación de Jupyter en el entorno virtual"

# Instalar paquetes esenciales para análisis de datos y ciencia de datos
print_message "yellow" "Instalando paquetes esenciales para análisis de datos..."
pip install pandas numpy matplotlib seaborn plotly bokeh
check_success "Instalación de paquetes esenciales para análisis de datos"

# Instalar paquetes para estadísticas y Machine Learning
print_message "yellow" "Instalando paquetes para estadísticas y Machine Learning..."
pip install scikit-learn xgboost lightgbm statsmodels scipy
check_success "Instalación de paquetes para estadísticas y Machine Learning"

# Instalar paquetes para procesamiento de datos
print_message "yellow" "Instalando paquetes para procesamiento de datos..."
pip install openpyxl xlrd sqlalchemy pymongo requests beautifulsoup4 lxml
check_success "Instalación de paquetes para procesamiento de datos"

# Instalar paquetes para NLP y Deep Learning (opcionales según necesidades)
print_message "yellow" "Instalando paquetes para NLP y Deep Learning..."
pip install nltk spacy gensim tensorflow keras
check_success "Instalación de paquetes para NLP y Deep Learning"

# Desactivar el entorno virtual
deactivate

# Configurar Jupyter para que use el tema seleccionado
print_message "yellow" "Configurando Jupyter con el tema $THEME_NAME..."

# Asegurar que existe el directorio de configuración
ensure_dir "$HOME/.jupyter"

# Reactivar el entorno virtual para las configuraciones
source "$DATAVENV_PATH/bin/activate"

# Crear archivo de configuración básico en el entorno virtual
jupyter notebook --generate-config
check_success "Generación de configuración de Jupyter"

# Instalar temas para JupyterLab dentro del entorno virtual
print_message "yellow" "Instalando temas para JupyterLab en el entorno virtual..."
pip install jupyterlab-theme-toggle

# Configurar tema según selección
case $THEME_NAME in
    "tokyo-night")
        pip install jupyterlab_tokyo_night
        sed -i "s/# c.JupyterLab.theme = ''/c.JupyterLab.theme = 'tokyo-night'/" "$HOME/.jupyter/jupyter_notebook_config.py"
        ;;
    "dracula")
        pip install jupyterlab-dracula-theme
        sed -i "s/# c.JupyterLab.theme = ''/c.JupyterLab.theme = 'jupyterlab-dracula-theme'/" "$HOME/.jupyter/jupyter_notebook_config.py"
        ;;
    "nord")
        pip install jupyterlab_nord
        sed -i "s/# c.JupyterLab.theme = ''/c.JupyterLab.theme = 'nord'/" "$HOME/.jupyter/jupyter_notebook_config.py"
        ;;
    *)
        print_message "yellow" "No hay un tema específico de $THEME_NAME para JupyterLab, usando tema oscuro por defecto"
        sed -i "s/# c.JupyterLab.theme = ''/c.JupyterLab.theme = 'JupyterLab Dark'/" "$HOME/.jupyter/jupyter_notebook_config.py"
        ;;
esac

# Crear kernel de IPython para el entorno virtual
print_message "yellow" "Creando kernel de IPython para el entorno virtual..."
python -m ipykernel install --user --name="$DATAVENV_NAME" --display-name="Python (Data Analytics)"
check_success "Creación del kernel para el entorno virtual"

# Desactivar el entorno virtual
deactivate

# Crear scripts para iniciar fácilmente JupyterLab con el entorno virtual
print_message "yellow" "Creando scripts para acceso rápido a JupyterLab..."

# Script para iniciar JupyterLab
cat > "$HOME/.local/bin/start-jupyter.sh" << EOF
#!/bin/bash
source "$DATAVENV_PATH/bin/activate"
jupyter lab
EOF
chmod +x "$HOME/.local/bin/start-jupyter.sh"

# Crear alias para iniciar JupyterLab
if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q "alias jlab=" "$HOME/.zshrc"; then
        echo "" >> "$HOME/.zshrc"
        echo "# Alias para JupyterLab (entorno virtual)" >> "$HOME/.zshrc"
        echo "alias jlab='$HOME/.local/bin/start-jupyter.sh'" >> "$HOME/.zshrc"
        echo "alias datavenv='source $DATAVENV_PATH/bin/activate'" >> "$HOME/.zshrc"
    fi
fi

if [ -f "$HOME/.bashrc" ]; then
    if ! grep -q "alias jlab=" "$HOME/.bashrc"; then
        echo "" >> "$HOME/.bashrc"
        echo "# Alias para JupyterLab (entorno virtual)" >> "$HOME/.bashrc"
        echo "alias jlab='$HOME/.local/bin/start-jupyter.sh'" >> "$HOME/.bashrc"
        echo "alias datavenv='source $DATAVENV_PATH/bin/activate'" >> "$HOME/.bashrc"
    fi
fi

# Asegurar que ~/.local/bin está en el PATH
ensure_dir "$HOME/.local/bin"
if ! echo $PATH | grep -q "$HOME/.local/bin"; then
    if [ -f "$HOME/.zshrc" ]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
    fi
    if [ -f "$HOME/.bashrc" ]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    fi
fi

# Crear entrada de escritorio para JupyterLab
cat > "$HOME/.local/share/applications/jupyterlab.desktop" << EOF
[Desktop Entry]
Name=JupyterLab
Comment=Interactive Data Science Environment
Exec=jupyter lab
Terminal=false
Type=Application
Icon=jupyter
Categories=Development;Science;
StartupNotify=true
EOF

print_message "green" "✓ Jupyter Notebook/Lab y paquetes para análisis de datos instalados correctamente"
print_message "yellow" "Para iniciar JupyterLab, ejecuta 'jupyter lab' o 'jlab' en la terminal"
print_message "yellow" "También puedes encontrar JupyterLab en el menú de aplicaciones"
