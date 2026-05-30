#!/bin/bash
# Bootstrap para dotfiles de jmrodev
set -e

echo "--- Iniciando Instalación de Dotfiles ---"

# 1. Clonar el repositorio bare
if [ ! -d "$HOME/.dotfiles" ]; then
    git clone --bare https://github.com/jmrodev/dotfiles.git "$HOME/.dotfiles"
fi

# 2. Definir comando temporal
function dotfiles_cmd {
    /usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" "$@"
}

# 3. Checkout (limpiando archivos de fábrica)
echo "Limpiando archivos de configuración básicos..."
rm -f "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.gitconfig"

echo "Aplicando checkout..."
dotfiles_cmd checkout || {
    echo "Error en checkout. Reintentando forzado..."
    dotfiles_cmd checkout -f
}

# 4. Configuración de visibilidad
dotfiles_cmd config --local status.showUntrackedFiles no

# 5. Lanzar el instalador pesado que ya está en el repo
if [ -f "$HOME/.config/zsh/scripts/setup_new_pc.sh" ]; then
    bash "$HOME/.config/zsh/scripts/setup_new_pc.sh"
else
    echo "Error: No se encontró el script de setup en la ruta esperada."
    exit 1
fi
