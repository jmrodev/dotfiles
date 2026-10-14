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

echo ""
echo "=========================================================="
echo "              ¡RESTAURACIÓN FINALIZADA!                  "
echo "=========================================================="
