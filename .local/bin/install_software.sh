#!/bin/bash
#
# Script para instalar todo el software y herramientas en una nueva instalación de Arch Linux.

# Detiene el script si algún comando falla
set -e

echo "🚀 Iniciando la configuración completa del sistema..."

# 1. Instalar Dependencias Esenciales
# -------------------------------------
sudo pacman -S --needed --noconfirm git base-devel curl zsh autoconf automake

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

# 4. Instalar plugins y tema de Oh My Zsh
# -----------------------------------------
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
# Powerlevel10k
if [ ! -d "${ZSH_CUSTOM}/themes/powerlevel10k" ]; then
    echo "Instalando el tema Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM}/themes/powerlevel10k"
else
    echo "El tema Powerlevel10k ya está instalado."
fi
# zsh-autosuggestions
if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]; then
    echo "Instalando zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
else
    echo "El plugin zsh-autosuggestions ya está instalado."
fi
# zsh-syntax-highlighting
if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]; then
    echo "Instalando zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
else
    echo "El plugin zsh-syntax-highlighting ya está instalado."
fi

# 5. Instalar Nerd Fonts (MesloLGS NF)
# --------------------------------------
FONT_DIR="$HOME/.local/share/fonts"
if [ ! -d "$FONT_DIR" ]; then
    echo "Creando el directorio de fuentes: $FONT_DIR"
    mkdir -p "$FONT_DIR"
fi

echo "Descargando e instalando la fuente MesloLGS NF..."
wget -P "$FONT_DIR" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
wget -P "$FONT_DIR" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
wget -P "$FONT_DIR" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
wget -P "$FONT_DIR" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf

echo "Actualizando la caché de fuentes..."
fc-cache -f -v

# 6. Corregir el archivo .zshrc
# -----------------------------
if [ -f "$HOME/.zshrc" ]; then
    echo "Corrigiendo el nombre del plugin de resaltado de sintaxis en .zshrc..."
    sed -i 's/zsh-syntax-hightlighting/zsh-syntax-highlighting/g' "$HOME/.zshrc"
fi

# 7. Lista de paquetes a instalar (Oficiales y AUR)
# ----------------------------------------------------
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
    "rofi-wifi-menu-git"
    "unarchiver"
    "wget"
    "wireplumber"
    "xfce4-artwork"
    "xorg-xbacklight"
    "xss-lock"
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
    "ttf-firacode-nerd"
    # Dependencias para Neovim y Mason
    "unzip"
    "rust"
    "luarocks"
    "ruby"
    "php"
    "composer"
    "jdk-openjdk"
    "go"
    # Servidores de Lenguaje (LSPs) para Neovim
    "clangd"
    "typescript-language-server"
    "python-lsp-server"
    "lua-language-server"
    "bash-language-server"
    "gopls"
)

# Paquetes globales de NPM (instalados con pnpm)
NPM_PACKAGES=(
    "@google/gemini-cli"
    "express-generator"
)

# 8. Proceso de Instalación de Software
# -------------------------------------
echo "Instalando todos los paquetes (oficiales y AUR) con yay..."
yay -S --needed --noconfirm "${ALL_PACKAGES[@]}"

echo "Instalando paquetes globales de NPM con pnpm..."
pnpm install -g "${NPM_PACKAGES[@]}"

# 9. Cambiar la Shell por Defecto a Zsh
# -------------------------------------
ZSH_PATH=$(which zsh)
if [ "$SHELL" != "$ZSH_PATH" ]; then
    echo "Cambiando la shell por defecto a Zsh para el usuario $USER..."
    sudo chsh -s "$ZSH_PATH" "$USER"
    echo "Verificando que el cambio se haya registrado en el sistema..."
    CONFIGURED_SHELL=$(getent passwd "$USER" | cut -d: -f7)
    if [ "$CONFIGURED_SHELL" = "$ZSH_PATH" ]; then
        echo "✅ Verificación exitosa: La shell por defecto ahora está configurada como $ZSH_PATH."
    else
        echo "❌ Error: No se pudo cambiar la shell automáticamente."
        echo "   Por favor, ejecuta este comando manualmente: sudo chsh -s $ZSH_PATH $USER"
    fi
else
    echo "La shell por defecto ya es Zsh. No se necesita ninguna acción."
fi

echo "-------------------------------------------------"
echo "✅ ¡Instalación de software y configuración completada!"
echo "🔴 IMPORTANTE: Cierra sesión y vuelve a iniciarla (o reinicia) para que todos los cambios tomen efecto."
echo "   Después de reiniciar, abre una terminal y ejecuta 'p10k configure' para configurar tu prompt."
echo "   Asegúrate de que tu terminal esté usando la fuente 'MesloLGS NF'."
echo "-------------------------------------------------"

# 10. Configurar Git para Dotfiles
# ---------------------------------
echo "Configurando el repositorio de dotfiles para ignorar archivos no rastreados..."
# Esta línea es crucial para que 'dotfiles status' no muestre todos los archivos del home
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME config status.showUntrackedFiles no
echo "Configuración de dotfiles aplicada."
