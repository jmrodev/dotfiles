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
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh no encontrado. Instalando..."
    # El flag --unattended lo instala sin iniciar zsh ni cambiar la shell automáticamente
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo "Oh My Zsh instalado exitosamente."
else
    echo "Oh My Zsh ya está instalado."
    read -p "¿Deseas reinstalarlo? (Esto eliminará la configuración existente) (s/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        echo "Eliminando la instalación anterior y reinstalando Oh My Zsh..."
        rm -rf "$HOME/.oh-my-zsh"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        echo "Oh My Zsh reinstalado exitosamente."
    else
        echo "Omitiendo la reinstalación de Oh My Zsh."
    fi
fi

# 3. Instalar yay si no está presente
# -------------------------------------
if ! command -v yay &> /dev/null; then
    echo "yay no encontrado. Instalando yay..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (
        cd /tmp/yay
        makepkg -s --noconfirm
        sudo pacman -U --noconfirm --needed *.pkg.tar.zst
    )
    rm -rf /tmp/yay
    echo "yay instalado exitosamente."
else
    echo "yay ya está instalado."
    read -p "¿Deseas reinstalarlo? (s/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        echo "Reinstalando yay..."
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        (
            cd /tmp/yay
            makepkg -s --noconfirm
            # Usamos -U sin --needed para forzar la reinstalación
            sudo pacman -U --noconfirm *.pkg.tar.zst
        )
        rm -rf /tmp/yay
        echo "yay reinstalado exitosamente."
    else
        echo "Omitiendo la reinstalación de yay."
    fi
fi

# 4. Lista de paquetes a instalar (Oficiales y AUR)
# -----------------------------------------------------
# yay gestionará automáticamente si vienen de los repositorios oficiales o del AUR.
ALL_PACKAGES=(
    "ark"
    "archlinux-wallpaper"
    "autorandr"
    "clipit"
    "dex"
    "dolphin-plugins"
    "dolphin-quick-view"
    "dunst"
    "eza"
    "fzf"
    "gammastep"
    "gh"
    "gnome-backgrounds"
    "libnotify"
    "lsof"
    "lua"
    "lua51"
    "lzop"
    "maim"
    "mousepad"
    "networkmanager"
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
    "pnpm"
    "pyenv-virtualenv"
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
    "unarchiver"
    "wget"
    "wireplumber"
    "xfce4-artwork"
    "xorg-xbacklight"
    "xss-lock"
    "zsh-autosuggestions"
    "zsh-syntax-highlighting"
    # Dependencias para atajos de i3
    "dmenu"
    "flameshot"
    "google-chrome"
    "neovim"
    "pcmanfm"
    "ranger"
    "xclip"
    "xdotool"
    "xfce4-terminal"
)

# Paquetes globales de NPM (instalados con pnpm)
NPM_PACKAGES=(
    "@google/gemini-cli"
    "express-generator"
)


# 5. Proceso de Instalación de Software
# -------------------------------------

echo "Instalando todos los paquetes (oficiales y AUR) con yay..."
yay -S --needed --noconfirm "${ALL_PACKAGES[@]}"

echo "Instalando paquetes globales de NPM con pnpm..."
# Se ejecuta sin sudo para instalar los paquetes en el directorio del usuario
pnpm install -g "${NPM_PACKAGES[@]}"

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
