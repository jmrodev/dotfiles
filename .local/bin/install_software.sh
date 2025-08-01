#!/bin/bash
#
# Script para instalar todo el software y herramientas en una nueva instalación de Arch Linux.
# Se asegura de que yay esté instalado y luego instala paquetes de los repositorios oficiales y del AUR.

# Detiene el script si algún comando falla
set -e

echo "Iniciando la configuración del sistema..."

# 1. Instalar yay si no está presente
# -------------------------------------
if ! command -v yay &> /dev/null; then
    echo "yay no encontrado. Instalando yay..."
    # Se necesitan git y base-devel para compilar paquetes
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
    rm -rf /tmp/yay
    echo "yay instalado exitosamente."
else
    echo "yay ya está instalado."
fi

# 2. Listas de paquetes
# ----------------------

# Paquetes de los repositorios oficiales de Arch (instalados con pacman)
PACMAN_PACKAGES=(
    "ark"
    "archlinux-wallpaper"
    "clipit"
    "curl"
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


# 3. Proceso de Instalación
# -------------------------

echo "Instalando paquetes de los repositorios oficiales con pacman..."
sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"

echo "Instalando paquetes del AUR con yay..."
yay -S --needed --noconfirm "${YAY_PACKAGES[@]}"

echo "Instalando paquetes globales de NPM con pnpm..."
sudo pnpm install -g "${NPM_PACKAGES[@]}"


echo "-------------------------------------------------"
echo "¡Instalación de software completada!"
echo "Reinicia tu sesión para asegurar que todos los cambios tomen efecto."
echo "-------------------------------------------------"

