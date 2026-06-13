#!/bin/bash
# Bootstrap para dotfiles de jmrodev
set -e

# Asegurar que estamos en el HOME
cd "$HOME"

echo "--- Iniciando Instalación de Dotfiles (Modo Ultra-Robusto) ---"

# 1. Clonar el repositorio bare si no existe
if [ ! -d "$HOME/.dotfiles" ]; then
    echo "Clonando repositorio bare..."
    git clone --bare https://github.com/jmrodev/dotfiles.git "$HOME/.dotfiles"
fi

# Función de ayuda para comandos git bare
function dotfiles_cmd {
    /usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" "$@"
}

# 2. ASEGURAR ÚLTIMA VERSIÓN DE GITHUB
echo "Sincronizando con GitHub..."
dotfiles_cmd remote set-url origin https://github.com/jmrodev/dotfiles.git
dotfiles_cmd fetch origin sway

# 3. Limpiar terreno
echo "Limpiando archivos de configuración básicos (ZSH, Git, Neovim)..."
rm -rf .zshrc .bashrc .gitconfig .p10k.zsh .config/nvim .config/ranger

# 4. FORZAR checkout desde origin/main
echo "Extrayendo archivos del repositorio..."
# Usamos read-tree y checkout-index para ser más agresivos que checkout -f
dotfiles_cmd read-tree --reset -u FETCH_HEAD

# 5. Configuración de visibilidad
dotfiles_cmd config --local status.showUntrackedFiles no

# 6. Lanzar el instalador pesado
SETUP_SCRIPT="$HOME/.config/zsh/scripts/setup_new_pc.sh"

# Verificación de emergencia: si no aparece, lo bajamos por curl
if [ ! -f "$SETUP_SCRIPT" ]; then
    echo "Aviso: El script no apareció tras el checkout. Descargando versión de emergencia..."
    mkdir -p "$(dirname "$SETUP_SCRIPT")"
    curl -sSL "https://raw.githubusercontent.com/jmrodev/dotfiles/sway/.config/zsh/scripts/setup_new_pc.sh" -o "$SETUP_SCRIPT"
fi

if [ -f "$SETUP_SCRIPT" ]; then
    echo "Lanzando instalador de sistema..."
    chmod +x "$SETUP_SCRIPT"
    bash "$SETUP_SCRIPT"
else
    echo "ERROR: No se pudo obtener el script de setup."
    exit 1
fi
