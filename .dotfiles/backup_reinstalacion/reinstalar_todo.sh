#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
AUTO_YES=false

if [[ "$1" == "-y" || "$1" == "--yes" || "$1" == "--all" ]]; then
    AUTO_YES=true
fi

ask() {
    local prompt="$1"
    if $AUTO_YES; then
        return 0
    fi
    read -p "$prompt [S/n]: " resp
    if [[ -z "$resp" || "$resp" =~ ^[sSyY]$ ]]; then
        return 0
    fi
    return 1
}

echo "=========================================================="
echo "      RESTAURADOR DE APLICACIONES - MANJARO SWAY          "
echo "=========================================================="
echo "Directorio de respaldo: $DIR"
echo ""

# 1. Paquetes oficiales
if ask "¿Instalar los paquetes oficiales de pacman?"; then
    echo ">> Actualizando base de datos e instalando paquetes oficiales..."
    sudo pacman -Syu --needed - < "$DIR/native_packages.txt"
fi

# 2. AUR (yay)
if ask "¿Instalar los paquetes de AUR con yay?"; then
    if ! command -v yay &>/dev/null; then
        echo ">> yay no está instalado. Instalándolo..."
        sudo pacman -S --needed --noconfirm base-devel git
        git clone https://aur.archlinux.org/yay.git /tmp/yay_build
        (cd /tmp/yay_build && makepkg -si --noconfirm)
        rm -rf /tmp/yay_build
    fi
    echo ">> Instalando paquetes de AUR..."
    yay -S --needed - < "$DIR/aur_packages.txt"
fi

# 3. Flatpaks
if ask "¿Instalar las aplicaciones Flatpak (Stremio y FLDIGI)?"; then
    if ! command -v flatpak &>/dev/null; then
        sudo pacman -S --needed --noconfirm flatpak
    fi
    echo ">> Añadiendo Flathub e instalando flatpaks..."
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    flatpak install flathub com.stremio.Stremio com.w1hkj.fldigi -y
fi

# 4. Scripts en /usr/local/bin
if ask "¿Restaurar scripts de /usr/local/bin (sway, pkexec)?"; then
    if [ -d "$DIR/usr_local_bin" ]; then
        echo ">> Copiando scripts a /usr/local/bin/..."
        sudo cp -r "$DIR/usr_local_bin"/* /usr/local/bin/
        sudo chmod +x /usr/local/bin/*
        echo "Scripts restaurados."
    fi
fi

# 5. Configuraciones del sistema (Docker daemon, udev rules)
if ask "¿Restaurar configuraciones del sistema (Docker daemon, udev rules)?"; then
    if [ -f "$DIR/docker-daemon.json" ]; then
        echo ">> Configurando /etc/docker/daemon.json..."
        sudo mkdir -p /etc/docker
        sudo cp "$DIR/docker-daemon.json" /etc/docker/daemon.json
    fi
    if [ -f "$DIR/99-ncr-printer.rules" ]; then
        echo ">> Copiando reglas udev..."
        sudo cp "$DIR/99-ncr-printer.rules" /etc/udev/rules.d/
        sudo udevadm control --reload-rules && sudo udevadm trigger || true
    fi
fi

# 6. Grupos y servicios
if ask "¿Configurar grupos de usuario y servicios systemd?"; then
    echo ">> Agregando usuario $USER a grupos críticos..."
    sudo usermod -aG docker,kvm,input,uucp,video,lp "$USER" || true

    echo ">> Habilitando servicios esenciales (docker, tailscale, bluetooth, avahi)..."
    sudo systemctl enable --now docker.service || true
    sudo systemctl enable --now tailscaled.service || true
    sudo systemctl enable --now bluetooth.service || true
    sudo systemctl enable --now avahi-daemon.service || true
fi

# 7. Entornos de desarrollo y herramientas CLI
if ask "¿Verificar/instalar entornos dev (uv, ollama)?"; then
    if ! command -v uv &>/dev/null; then
        echo ">> Instalando uv..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
    fi
    if ! command -v ollama &>/dev/null; then
        echo ">> Instalando Ollama..."
        curl -fsSL https://ollama.com/install.sh | sh
    fi
fi

# 8. Servicios de usuario (Navidrome)
if ask "¿Levantar servidor de música Navidrome?"; then
    if [ -f "$HOME/.config/navidrome/docker-compose.yml" ]; then
        echo ">> Iniciando contenedor Navidrome..."
        (cd "$HOME/.config/navidrome" && docker compose up -d) || true
    fi
fi

echo ""
echo "=========================================================="
echo "              ¡RESTAURACIÓN FINALIZADA!                  "
echo "=========================================================="
echo "Recomendación: Reinicia el equipo para aplicar permisos de grupos (docker, kvm, etc.)."
