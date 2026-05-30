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
fi

# Función de ayuda para comandos git bare
function dotfiles_cmd {
    /usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" "$@"
}

# 2. ASEGURAR ÚLTIMA VERSIÓN DE GITHUB (Muy importante)
echo "Trayendo cambios más recientes desde GitHub..."
dotfiles_cmd remote set-url origin https://github.com/jmrodev/dotfiles.git
dotfiles_cmd fetch origin main

# 3. Preparar checkout (Limpieza)
echo "Limpiando posibles conflictos..."
rm -f .zshrc .bashrc .gitconfig .p10k.zsh

# 4. Aplicar checkout apuntando a origin/main
echo "Sincronizando archivos (Checkout)..."
# Forzamos el checkout para que los archivos aparezcan físicamente
if ! dotfiles_cmd checkout -f main; then
    echo "Fallo el checkout forzado. Intentando resetear el índice..."
    dotfiles_cmd reset --hard origin/main
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
    echo "Intentando buscarlo en el repositorio..."
    if dotfiles_cmd ls-tree -r HEAD --name-only | grep -q "setup_new_pc.sh"; then
        echo "El archivo existe en el repo pero no en el disco. Reintentando checkout quirúrgico..."
        dotfiles_cmd checkout -f main -- .config/zsh/scripts/setup_new_pc.sh
        if [ -f "$SETUP_SCRIPT" ]; then
            bash "$SETUP_SCRIPT"
            exit 0
        fi
    fi
    exit 1
fi
