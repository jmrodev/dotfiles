#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

echo "=========================================================="
echo "      RESTAURADOR DE APLICACIONES - MANJARO SWAY          "
echo "=========================================================="
echo "Directorio de respaldo: $DIR"
echo ""

read -p "¿Deseas instalar los paquetes oficiales de pacman? (s/N): " resp1
if [[ "$resp1" =~ ^[sSyY]$ ]]; then
    echo ">> Actualizando base de datos e instalando paquetes oficiales..."
    sudo pacman -Syu --needed - < "$DIR/native_packages.txt"
fi

read -p "¿Deseas instalar los paquetes de AUR con yay? (s/N): " resp2
if [[ "$resp2" =~ ^[sSyY]$ ]]; then
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

read -p "¿Deseas instalar las aplicaciones Flatpak (Stremio y FLDIGI)? (s/N): " resp3
if [[ "$resp3" =~ ^[sSyY]$ ]]; then
    if ! command -v flatpak &>/dev/null; then
        sudo pacman -S --needed flatpak
    fi
    echo ">> Añadiendo Flathub e instalando flatpaks..."
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    flatpak install flathub com.stremio.Stremio com.w1hkj.fldigi -y
fi

read -p "¿Deseas restaurar los scripts de /usr/local/bin (sway, pkexec)? (s/N): " resp4
if [[ "$resp4" =~ ^[sSyY]$ ]]; then
    if [ -d "$DIR/usr_local_bin" ]; then
        echo ">> Copiando scripts a /usr/local/bin/..."
        sudo cp -r "$DIR/usr_local_bin"/* /usr/local/bin/
        sudo chmod +x /usr/local/bin/*
        echo "Scripts restaurados."
    fi
fi

read -p "¿Deseas restaurar configuraciones del sistema (Docker daemon, udev rules)? (s/N): " resp_sys
if [[ "$resp_sys" =~ ^[sSyY]$ ]]; then
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

read -p "¿Deseas configurar grupos de usuario (docker, kvm, input, etc.) y servicios systemd? (s/N): " resp_groups
if [[ "$resp_groups" =~ ^[sSyY]$ ]]; then
    echo ">> Agregando usuario $USER a grupos críticos..."
    sudo usermod -aG docker,kvm,input,uucp,video,lp "$USER" || true

    echo ">> Habilitando servicios esenciales (docker, tailscale, bluetooth, avahi)..."
    sudo systemctl enable --now docker.service || true
    sudo systemctl enable --now tailscaled.service || true
    sudo systemctl enable --now bluetooth.service || true
    sudo systemctl enable --now avahi-daemon.service || true
fi

read -p "¿Deseas verificar/instalar entornos dev (uv, node global, bun)? (s/N): " resp_dev
if [[ "$resp_dev" =~ ^[sSyY]$ ]]; then
    if ! command -v uv &>/dev/null; then
        echo ">> Instalando uv (gestor ultra rápido de Python)..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
    fi
fi

echo ""
echo "=========================================================="
echo "              ¡RESTAURACIÓN FINALIZADA!                  "
echo "=========================================================="
