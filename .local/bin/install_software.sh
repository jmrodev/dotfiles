#!/bin/bash
#
# Script para instalar todo el software y herramientas en una nueva instalación de Arch Linux o Void Linux.

# Detiene el script si algún comando falla
set -e

# --- Detección del Sistema Operativo ---
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_ID=$ID
else
    echo "No se pudo detectar el sistema operativo."
    exit 1
fi

echo "🚀 Iniciando la configuración completa del sistema para $PRETTY_NAME..."

# --- Definición de Paquetes ---
# Paquetes para Arch Linux (incluye AUR)
ARCH_PACKAGES=(
    "ark" "archlinux-wallpaper" "autorandr" "clipit" "dex" "dolphin-plugins"
    "dolphin-quick-view" "dunst" "eza" "fzf" "gammastep" "gh" "gnome-backgrounds"
    "libnotify" "lsof" "lua" "lua51" "lzop" "maim" "mousepad" "networkmanager"
    "nitrogen" "numlockx" "p7zip" "pavucontrol" "picom" "pipewire" "pipewire-alsa"
    "pipewire-audio" "pipewire-jack" "pipewire-pulse" "pnpm" "pyenv-virtualenv"
    "rofi" "rofi-autorandr" "rofi-bluetooth-git" "rofi-browser" "rofi-calc"
    "rofi-gh" "rofi-mpc" "rofi-mpd" "rofi-power-menu" "rofi-randr"
    "rofi-wifi-menu-git" "unarchiver" "wget" "wireplumber" "xfce4-artwork"
    "xorg-xbacklight" "xss-lock" "dmenu" "flameshot" "google-chrome" "neovim"
    "pcmanfm" "ranger" "xclip" "xdotool" "xfce4-terminal" "ttf-firacode-nerd"
    "feh" "zathura" "mpd" "mpc" "unzip" "rust" "luarocks" "ruby" "php"
    "composer" "jdk-openjdk" "go" "typescript-language-server" "python-lsp-server"
    "lua-language-server" "bash-language-server" "gopls" "gnome-keyring"
    "network-manager-applet" "volumeicon" "i3lock" "i3blocks"
)

# Paquetes para Void Linux
VOID_PACKAGES=(
    "ark" "autorandr" "clipit" "dex" "dunst" "exa" "fzf" "gammastep" "gh"
    "libnotify" "lsof" "lua" "lzop" "maim" "mousepad" "NetworkManager"
    "nitrogen" "numlockx" "p7zip" "pavucontrol" "picom" "pipewire"
    "alsa-pipewire" "pnpm" "rofi" "wget" "wireplumber"
    "xorg-xbacklight" "xss-lock" "dmenu" "flameshot" "neovim" "pcmanfm"
    "ranger" "xclip" "xdotool" "xfce4-terminal" "nerd-fonts" "feh" "zathura"
    "mpd" "mpc" "unzip" "rust" "luarocks" "ruby" "php" "composer" "openjdk" "go"
    "typescript-language-server" "python-lsp-server" "lua-language-server"
    "bash-language-server" "gopls" "gnome-keyring" "NetworkManager-applet"
    "volumeicon" "i3lock" "i3blocks"
)

# Paquetes para Debian/Ubuntu
DEBIAN_PACKAGES=(
    "ark" "autorandr" "clipit" "dex" "dunst" "exa" "fzf" "gammastep" "gh" "libnotify-bin"
    "lsof" "lua5.1" "lzop" "maim" "mousepad" "network-manager" "nitrogen" "numlockx"
    "p7zip-full" "pavucontrol" "picom" "pipewire" "pipewire-audio-client-libraries"
    "pipewire-jack" "rofi" "wget" "wireplumber" "xbacklight" "xss-lock" "dmenu"
    "flameshot" "neovim" "pcmanfm" "ranger" "xclip" "xdotool" "xfce4-terminal" "feh"
    "zathura" "mpd" "mpc" "unzip" "rustc" "luarocks" "ruby-full" "php-cli" "composer"
    "default-jdk" "golang" "node-typescript" "python3-pylsp" "bash-language-server"
    "gnome-keyring" "network-manager-gnome" "volumeicon-alsa" "i3lock" "i3blocks"
    "fontconfig"
)

# Paquetes globales de NPM (comunes)
NPM_PACKAGES=(
    "@google/gemini-cli"
    "express-generator"
)


# 1. Instalar Dependencias Esenciales y Software
# ----------------------------------------------
case "$OS_ID" in
    "arch")
        echo "Sistema Arch Linux detectado. Usando pacman y yay."

        # Instalar dependencias básicas
        sudo pacman -S --needed --noconfirm git base-devel curl zsh autoconf automake clang clangd

        # Instalar yay si no está presente
        if ! command -v yay &> /dev/null; then
            echo "yay no encontrado. Instalando..."
            git clone https://aur.archlinux.org/yay.git /tmp/yay
            (cd /tmp/yay && makepkg -si --noconfirm)
            rm -rf /tmp/yay
            echo "yay instalado exitosamente."
        else
            echo "yay ya está instalado."
        fi

        # Instalar todos los paquetes
        yay -S --needed --noconfirm "${ARCH_PACKAGES[@]}"

        # Configuración específica de Arch (systemd)
        echo "Configurando el boton de apagado del sistema con logind..."
        SYSTEM_CONF="/etc/systemd/logind.conf"
        DOTFILES_CONF="$HOME/.dotfiles/systemd/logind.conf"
        mkdir -p "$(dirname "$DOTFILES_CONF")"
        if [ ! -f "$DOTFILES_CONF" ]; then
            sudo cp "$SYSTEM_CONF" "$DOTFILES_CONF"
        fi
        sed -i 's/^#HandlePowerKey=.*/HandlePowerKey=poweroff/' "$DOTFILES_CONF"
        if [ ! -L "$SYSTEM_CONF" ]; then
            sudo mv "$SYSTEM_CONF" "$SYSTEM_CONF.bak" 2>/dev/null || true
            sudo ln -sfn "$DOTFILES_CONF" "$SYSTEM_CONF"
        fi
        sudo systemctl restart systemd-logind.service
        echo "IMPORTANTE: El archivo '$DOTFILES_CONF' ha sido modificado. Añádelo a git."

        ;;
    "void")
        echo "Sistema Void Linux detectado. Usando xbps."

        # Instalar dependencias básicas y todos los paquetes
        sudo xbps-install -S --yes git xtools curl zsh autoconf automake clang
        sudo xbps-install -S --yes "${VOID_PACKAGES[@]}"
        ;;
    "debian" | "ubuntu" | "pop")
        echo "Sistema basado en Debian detectado. Usando apt."

        # Actualizar repositorios e instalar paquetes
        sudo apt-get update
        sudo apt-get install -y git build-essential curl zsh autoconf automake clang
        sudo apt-get install -y "${DEBIAN_PACKAGES[@]}"
        ;;
    *)
        echo "Distribución no soportada: $OS_ID"
        exit 1
        ;;
esac


# 2. Instalar Oh My Zsh (Común para ambos)
# -----------------------------------------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Instalando Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "Oh My Zsh ya está instalado."
fi


# 3. Instalar plugins y tema de Oh My Zsh (Común)
# -------------------------------------------------
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
# Powerlevel10k
if [ ! -d "${ZSH_CUSTOM}/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM}/themes/powerlevel10k"
fi
# zsh-autosuggestions
if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
fi
# zsh-syntax-highlighting
if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
fi


# 4. Instalar Nerd Fonts (MesloLGS NF) - Manualmente (Común)
# ----------------------------------------------------------
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
declare -A fonts
fonts["MesloLGS NF Regular.ttf"]="https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf"
fonts["MesloLGS NF Bold.ttf"]="https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf"
fonts["MesloLGS NF Italic.ttf"]="https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf"
fonts["MesloLGS NF Bold Italic.ttf"]="https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf"

FONTS_INSTALLED=false
for font_name in "${!fonts[@]}"; do
    if [ ! -f "$FONT_DIR/$font_name" ]; then
        echo "Descargando $font_name..."
        wget -O "$FONT_DIR/$font_name" "${fonts[$font_name]}"
        FONTS_INSTALLED=true
    fi
done

if [ "$FONTS_INSTALLED" = true ]; then
    echo "Actualizando la caché de fuentes..."
    fc-cache -f -v
fi


# 5. Corregir .zshrc (Común)
# --------------------------
if [ -f "$HOME/.zshrc" ]; then
    sed -i 's/zsh-syntax-hightlighting/zsh-syntax-highlighting/g' "$HOME/.zshrc"
fi


# 6. Instalar paquetes de NPM (Común)
# -----------------------------------
if command -v pnpm &> /dev/null; then
    echo "Instalando paquetes globales de NPM con pnpm..."
    pnpm install -g "${NPM_PACKAGES[@]}"
else
    echo "ADVERTENCIA: pnpm no está instalado. Omitiendo la instalación de paquetes de NPM."
fi


# 7. Cambiar la Shell por Defecto a Zsh (Común)
# ---------------------------------------------
ZSH_PATH=$(which zsh)
if [ "$SHELL" != "$ZSH_PATH" ]; then
    echo "Cambiando la shell por defecto a Zsh para el usuario $USER..."
    sudo chsh -s "$ZSH_PATH" "$USER"
    echo "Verificación: $(getent passwd "$USER" | cut -d: -f7)"
else
    echo "La shell por defecto ya es Zsh."
fi


# 8. Configurar Git para Dotfiles (Común)
# ---------------------------------------
echo "Configurando el repositorio de dotfiles para ignorar archivos no rastreados..."
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME config status.showUntrackedFiles no


echo "-------------------------------------------------"
echo "✅ ¡Instalación de software y configuración completada!"
echo "🔴 IMPORTANTE: Cierra sesión y vuelve a iniciarla (o reinicia) para que todos los cambios tomen efecto."
echo "   Si es la primera vez, ejecuta 'p10k configure' para configurar tu prompt."
echo "-------------------------------------------------"