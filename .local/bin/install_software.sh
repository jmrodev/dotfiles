#!/bin/bash
#
# Script para instalar todo el software y herramientas en una nueva instalación de Arch Linux.

# Detiene el script si algún comando falla
set -e

echo "🚀 Iniciando la configuración completa del sistema..."

# 1. Instalar Dependencias Esenciales
# -------------------------------------
sudo pacman -S --needed --noconfirm git base-devel curl zsh

# 2. Instalar Oh My Zsh
# -------------------------------------
#:if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh no encontrado. Instalando..."
    # El flag --unattended lo instala sin iniciar zsh ni cambiar la shell automáticamente
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo "Oh My Zsh instalado exitosamente."
else
    echo "Oh My Zsh ya está instalado."
fi

# 3. Instalar yay si no está presente
# -------------------------------------
if ! command -v yay &> /dev/null; then
    echo "yay no encontrado. Instalando yay..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
    rm -rf /tmp/yay
    echo "yay instalado exitosamente."
else
    echo "yay ya está instalado."
fi

# 4. Listas de paquetes
# ----------------------

# Paquetes de los repositorios oficiales de Arch (instalados con pacman)
PACMAN_PACKAGES=(
    "ark"
    "archlinux-wallpaper"
    "clipit"
    "dex"
    "dunst"
    "gammastep"
    "gnome-backgrounds"
    "libnotify"
    "lsof"
    "lua"
    "lua51"
    "lzop"
    "nitrogen"
    "numlockx"
    "p7zip"
    "pavucontrol"
    "picom"
    "pipewire"
    "pipewire-alsa"
    "pipewire-audio"
    "pipewire-jack"
    "pipewire-pulse"
    "unarchiver"
    "wget"
    "wireplumber"
    "xorg-xbacklight"
    "xfce4-artwork"
    "xss-lock"
)

# Paquetes del AUR (instalados con yay)
YAY_PACKAGES=(
    "autorandr"
    "dolphin-meld"
    "dolphin-plugins"
    "dolphin-quick-view"
    "eza"
    "fzf"
    "gh"
    "maim"
    "mousepad"
    "nmcli"
    "pnpm"
    "pyenv-virtualenv" # <-- AÑADIDO AQUÍ
    "rofi"
    "rofi-autorandr"
    "rofi-bluetooth-git"
    "rofi-browser"
    "rofi-calc"
    "rofi-gh"
    "rofi-mpc"
    "rofi-mpd"
    "rofi-power-menu"
    "rofi-randr"
    "rofi-screenshot-git"
    "rofi-search-git"
    "rofi-wifi-menu-git"
    "zsh-autosuggestions"
    "zsh-syntax-highlighting"
)

# Paquetes globales de NPM (instalados con pnpm)
NPM_PACKAGES=(
    "@google/gemini-cli"
    "express-generator"
)


# 5. Proceso de Instalación de Software
# -------------------------------------

echo "Instalando paquetes de los repositorios oficiales con pacman..."
sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"

echo "Instalando paquetes del AUR con yay..."
yay -S --needed --noconfirm "${YAY_PACKAGES[@]}"

echo "Instalando paquetes globales de NPM con pnpm..."
sudo pnpm install -g "${NPM_PACKAGES[@]}"

# 6. Cambiar la Shell por Defecto a Zsh
# -------------------------------------
ZSH_PATH=$(which zsh)
if [ "$SHELL" != "$ZSH_PATH" ]; then
    echo "Cambiando la shell por defecto a Zsh. Se requerirá tu contraseña."
    chsh -s "$ZSH_PATH"
    echo "La shell ha sido cambiada. El cambio tomará efecto en el próximo inicio de sesión."
else
    echo "La shell por defecto ya es Zsh."
fi


echo "-------------------------------------------------"
echo "✅ ¡Instalación de software y configuración completada!"
echo "🔴 IMPORTANTE: Cierra sesión y vuelve a iniciarla (o reinicia) para que todos los cambios tomen efecto."
echo "-------------------------------------------------"
