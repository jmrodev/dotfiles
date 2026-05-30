#!/bin/bash
# Bootstrap para dotfiles de jmrodev
set -e

# Asegurar que estamos en el HOME
cd "$HOME"

echo "--- Iniciando Instalación de Dotfiles ---"

# 1. Clonar el repositorio bare si no existe
if [ ! -d "$HOME/.dotfiles" ]; then
    echo "Clonando repositorio bare..."
    git clone --bare https://github.com/jmrodev/dotfiles.git "$HOME/.dotfiles"
else
    echo "El repositorio .dotfiles ya existe. Asegurando origen correcto..."
    /usr/bin/git --git-dir="$HOME/.dotfiles/" remote set-url origin https://github.com/jmrodev/dotfiles.git
fi

# 2. Función de ayuda
function dotfiles_cmd {
    /usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" "$@"
}

# 3. Preparar checkout
echo "Preparando el terreno (limpiando posibles conflictos)..."
# Borramos archivos que suelen venir por defecto y bloquean el checkout
rm -f .zshrc .bashrc .gitconfig .p10k.zsh .bash_history .bash_logout .profile

# 4. Aplicar checkout
echo "Sincronizando archivos del repositorio..."
if ! dotfiles_cmd checkout; then
    echo "Conflicto detectado. Forzando checkout (Sobrescribiendo archivos locales)..."
    dotfiles_cmd checkout -f
fi

# 5. Configuración de visibilidad
dotfiles_cmd config --local status.showUntrackedFiles no

# 6. Lanzar el instalador pesado
SETUP_SCRIPT="$HOME/.config/zsh/scripts/setup_new_pc.sh"
if [ -f "$SETUP_SCRIPT" ]; then
    echo "Lanzando instalador de sistema..."
    chmod +x "$SETUP_SCRIPT"
    bash "$SETUP_SCRIPT"
else
    echo "ERROR CRÍTICO: No se encontró el script de setup en: $SETUP_SCRIPT"
    echo "Contenido de ~/.config/zsh/scripts/:"
    ls -F "$HOME/.config/zsh/scripts/" 2>/dev/null || echo "La carpeta no existe."
    exit 1
fi
