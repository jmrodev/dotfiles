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

# Variable para saber si necesitamos actualizar la caché
FONTS_INSTALLED=false

# --- Descargar cada fuente solo si no existe ---
# Usamos un array para hacerlo más limpio y fácil de extender
declare -A fonts
fonts["MesloLGS NF Regular.ttf"]="https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf"
fonts["MesloLGS NF Bold.ttf"]="https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf"
fonts["MesloLGS NF Italic.ttf"]="https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf"
fonts["MesloLGS NF Bold Italic.ttf"]="https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf"

for font_name in "${!fonts[@]}"; do
    if [ ! -f "$FONT_DIR/$font_name" ]; then
        echo "Descargando $font_name..."
        # Usamos -O para especificar el nombre de archivo exacto y evitar duplicados .1, .2, etc.
        wget -O "$FONT_DIR/$font_name" "${fonts[$font_name]}"
        FONTS_INSTALLED=true
    else
        echo "Fuente '$font_name' ya instalada. Omitiendo."
    fi
done

# --- Actualizar la caché solo si se instalaron fuentes nuevas ---
if [ "$FONTS_INSTALLED" = true ]; then
    echo "Se instalaron fuentes nuevas. Actualizando la caché de fuentes..."
    fc-cache -f -v
else
    echo "Todas las fuentes ya estaban presentes. No se necesita actualizar la caché."
fi

# 6. Corregir el archivo .zshrc
# -----------------------------
if [ -f "$HOME/.zshrc" ]; then
    echo "Corrigiendo el nombre del plugin de resaltado de sintaxis en .zshrc..."
    sed -i 's/zsh-syntax-hightlighting/zsh-syntax-highlighting/g' "$HOME/.zshrc"
fi

# 7. Configurar logind.conf para el boton de apagado
# ----------------------------------------------------
echo "Configurando el boton de apagado del sistema con logind..."

# Path del archivo de configuración del sistema
SYSTEM_CONF="/etc/systemd/logind.conf"

# Path en tu repositorio de dotfiles
DOTFILES_CONF="$HOME/.dotfiles/systemd/logind.conf"

# 1. Asegurarse de que el directorio en dotfiles exista
mkdir -p "$(dirname "$DOTFILES_CONF")"

# 2. Copiar el archivo de configuración si no existe en dotfiles
if [ ! -f "$DOTFILES_CONF" ]; then
    echo "Copiando '$SYSTEM_CONF' al repositorio de dotfiles..."
    # Asegúrate de usar sudo para leer el archivo del sistema
    sudo cp "$SYSTEM_CONF" "$DOTFILES_CONF"
else
    echo "El archivo '$DOTFILES_CONF' ya existe en el repositorio."
fi

# 3. Editar el archivo en el repositorio
echo "Activando el 'poweroff' para el boton de encendido en el archivo del repositorio."
# Usamos sed para descomentar la línea y asegurar el valor
sed -i 's/^#HandlePowerKey=.*/HandlePowerKey=poweroff/' "$DOTFILES_CONF"

# 4. Crear el enlace simbólico si no existe
if [ ! -L "$SYSTEM_CONF" ]; then
    echo "Creando un enlace simbólico de '$DOTFILES_CONF' a '$SYSTEM_CONF'..."
    # Si el archivo original existe, lo movemos como backup
    if [ -f "$SYSTEM_CONF" ]; then
        sudo mv "$SYSTEM_CONF" "$SYSTEM_CONF.bak"
    fi
    # Crear el enlace simbólico. Usa '-sfn' para forzar, evitar errores y no preguntar
    sudo ln -sfn "$DOTFILES_CONF" "$SYSTEM_CONF"
else
    echo "El enlace simbólico ya existe. No se necesita ninguna acción."
fi

echo "Verificando el enlace simbólico..."
if [ -L "$SYSTEM_CONF" ]; then
    echo "✅ El enlace simbólico fue creado exitosamente."
else
    echo "❌ Error: No se pudo crear el enlace simbólico. El script continuará."
fi

# 5. Reiniciar el servicio para aplicar los cambios
echo "Reiniciando el servicio systemd-logind para aplicar los cambios..."
sudo systemctl restart systemd-logind.service

# 6. Agregar al repositorio de Git (esto lo harás manualmente con tu alias)
# Este paso no es automático para evitar commits no deseados, pero el script
# te deja el archivo preparado para que lo agregues con tu alias `dotfiles`.
echo " IMPORTANTE: El archivo de configuracion '$DOTFILES_CONF' se ha modificado. "
echo "   Por favor, ejecuta 'dotfiles add systemd/logind.conf' y luego 'dotfiles commit' para guardar los cambios."

# 8. Lista de paquetes a instalar (Oficiales y AUR)
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
    "gnome-keyring"
    "network-manager-applet"
    "volumeicon"
    "i3lock"
    "i3blocks"
)

# Paquetes globales de NPM (instalados con pnpm)
NPM_PACKAGES=(
    "@google/gemini-cli"
    "express-generator"
)

# 9. Proceso de Instalación de Software
# -------------------------------------
echo "Instalando todos los paquetes (oficiales y AUR) con yay..."
yay -S --needed --noconfirm "${ALL_PACKAGES[@]}"

echo "Instalando paquetes globales de NPM con pnpm..."
pnpm install -g "${NPM_PACKAGES[@]}"

# 10. Cambiar la Shell por Defecto a Zsh
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

# 11. Configurar Git para Dotfiles
# ---------------------------------
echo "Configurando el repositorio de dotfiles para ignorar archivos no rastreados..."
# Esta línea es crucial para que 'dotfiles status' no muestre todos los archivos del home
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME config status.showUntrackedFiles no
echo "Configuración de dotfiles aplicada."