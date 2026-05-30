#!/bin/bash
# ==============================================================================
# UNIVERSAL SETUP SCRIPT - Hardware Agnostic (Fer Edition)
# Este script automatiza la clonación de dotfiles y la instalación de software.
# Regla de Oro: SIEMPRE SUMAR.
# ==============================================================================

set -e

# --- 0. VARIABLES Y COLORES ---
DOTFILES_REPO="https://github.com/jmrodev/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Iniciando Setup Universal de Sistema...${NC}"

# --- 1. BOOTSTRAP DOTFILES (BARE REPO) ---
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Clonando repositorio bare..."
    git clone --bare "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

function dotfiles {
   /usr/bin/git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" "$@"
}

echo "Limpiando archivos de configuración por defecto para evitar conflictos..."
# Archivos que suelen dar conflicto en el checkout
rm -f "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.gitconfig" "$HOME/.bash_profile" "$HOME/.p10k.zsh"

echo "Aplicando checkout de archivos reales..."
dotfiles checkout
dotfiles config --local status.showUntrackedFiles no

# --- 2. DETECCIÓN DE HARDWARE INTELIGENTE ---
echo "--- Detectando Hardware ---"
if lspci | grep -qi "Realtek" && lspci | grep -qi "8723de"; then
    echo -e "${BLUE}✔ Detectado Wifi Realtek RTL8723DE. Aplicando parches de estabilidad...${NC}"
    cat <<EOF | sudo tee /etc/modprobe.d/rtw88.conf
options rtw88_core disable_lps_deep=Y
options rtw88_pci disable_aspm=Y
EOF
else
    echo "Hardware específico no detectado. Saltando parches de wifi."
fi

# --- 3. OPTIMIZACIÓN DE SISTEMA Y MEMORIA ---
echo "--- Optimizando Sistema (ZRAM y Performance) ---"
if command -v pacman &>/dev/null; then
    sudo pacman -S --needed --noconfirm zram-generator
    cat <<EOF | sudo tee /etc/systemd/zram-generator.conf
[zram0]
zram-size = ram
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
EOF
    sudo systemctl daemon-reload
    sudo systemctl start /dev/zram0
fi

# --- 4. INSTALACIÓN DE SOFTWARE (ARCH/MANJARO) ---
if command -v pacman &>/dev/null; then
    echo "Actualizando mirrors y sistema..."
    sudo pacman-mirrors -f 5 || true
    sudo pacman -Syu --noconfirm

    echo "Instalando gestor AUR (yay)..."
    sudo pacman -S --needed --noconfirm base-devel git
    if ! command -v yay &>/dev/null; then
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        (cd /tmp/yay && makepkg -si --noconfirm)
    fi

    echo "Instalando paquetes esenciales (Lista unificada)..."
    PACKAGES=(
        "eza" "bat" "fzf" "neovim" "lazygit" "btop" "zoxide" "fastfetch" 
        "pnpm" "docker" "docker-compose" "gh" "trello-cli" "yt-dlp" "ranger"
        "ripgrep" "fd" "unzip" "gcc" "make"
        "pipewire" "pipewire-pulse" "pipewire-alsa" "wireplumber"
        "p7zip" "unarchiver" "wget" "lsof" "flameshot" "google-chrome"
    )
    yay -S --needed --noconfirm "${PACKAGES[@]}"
fi

# --- 5. CONFIGURACIONES FINALES ---
echo "Habilitando servicios..."
sudo systemctl enable --now docker || true

echo "Configurando ZSH como shell por defecto..."
if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s "$(which zsh)"
fi

echo -e "${BLUE}✅ SETUP COMPLETADO CON ÉXITO.${NC}"
echo "Por favor, reinicia la sesión para aplicar todos los cambios."
