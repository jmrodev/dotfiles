#!/usr/bin/env bash

# ==================================================
# Script de Configuración Inicial para Manjaro i3
# ==================================================
# Ejecutar con: bash setup_manjaro_i3.sh
# O hacerlo ejecutable (chmod +x setup_manjaro_i3.sh) y ejecutar: ./setup_manjaro_i3.sh
# ¡IMPORTANTE! Ejecutar en una terminal para introducir la contraseña de sudo
# y ver el progreso/errores.

# Opcional: Salir inmediatamente si un comando falla
set -e

echo ">>> Iniciando configuración de Manjaro i3..."

# --- 1. Actualizar el sistema ---
echo ">>> Actualizando base de datos y sistema (requiere sudo)..."
sudo pacman -Syu --noconfirm || { echo "¡Fallo al actualizar el sistema!"; exit 1; }

# --- 2. Instalar Yay (Ayudante AUR) si no existe ---
if ! command -v yay &> /dev/null; then
    echo ">>> Yay no encontrado. Instalando yay..."
    sudo pacman -S --needed --noconfirm git base-devel || { echo "¡Fallo al instalar dependencias para yay!"; exit 1; }
    cd /tmp # Ir a un directorio temporal
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm || { echo "¡Fallo al compilar/instalar yay!"; exit 1; }
    cd ..
    rm -rf yay # Limpiar
    echo ">>> Yay instalado correctamente."
else
    echo ">>> Yay ya está instalado."
fi

# --- 3. Instalar Paquetes Esenciales y Recomendados (Oficiales + AUR) ---
echo ">>> Instalando paquetes principales usando Yay (requiere sudo)..."

# Lista de paquetes (añade o quita según necesites)
PACKAGES=(
    # --- Esenciales / Sistema / Utilidades ---
    i3-gaps                  # Gestor de ventanas (si no usas i3-wm normal)
    i3status                 # Barra de estado simple
    dmenu-manjaro            # Lanzador básico (dependencia de i3-wm a veces)
    alacritty                # Terminal
    rofi                     # Lanzador avanzado
    thunar                   # Gestor de archivos
    gvfs                     # Para montar unidades con Thunar/Nemo etc.
    feh                      # Visor/Gestor de fondos
    nitrogen                 # Alternativa gráfica para fondos
    picom                    # Compositor
    dunst                    # Notificaciones
    libnotify                # Biblioteca para notificaciones
    flameshot                # Capturas de pantalla
    copyq                    # Gestor de portapapeles
    lxappearance             # Configuración de temas GTK
    papirus-icon-theme       # Set de iconos
    ttf-firacode-nerd        # Fuente con iconos
    brightnessctl            # Control de brillo
    pavucontrol              # Control gráfico de volumen
    bluez                    # Bluetooth stack
    bluez-utils              # Utilidades Bluetooth
    blueman                  # Applet gráfico Bluetooth
    network-manager-applet   # Applet de red
    firefox                  # Navegador
    htop                     # Monitor de sistema (terminal)
    btop                     # Monitor de sistema moderno (terminal)
    tlp                      # Gestión de energía laptop (necesita 'sudo systemctl enable tlp.service')
    tlp-rdw                  # Para TLP con NetworkManager/ModemManager
    yad                      # Para diálogos gráficos (usado en la ayuda de i3)
    archlinux-keyring        # Asegurar que las llaves de Arch/Manjaro están actualizadas
    manjaro-keyring          # Llaves específicas de Manjaro

    # --- AUR (Yay los buscará aquí si no están en repos oficiales) ---
    i3lock-color             # Bloqueador de pantalla personalizable
    # visual-studio-code-bin # VS Code (binario)
    # polybar                  # Barra de estado alternativa (AUR o repo community)
    # brave-bin                # Navegador Brave (binario)
)

# Instalar todos los paquetes de la lista
yay -S --needed --noconfirm "${PACKAGES[@]}" || { echo "¡Fallo al instalar uno o más paquetes!"; exit 1; }

echo ">>> Paquetes instalados correctamente."

# --- 4. Configurar Servicios (Opcional) ---
echo ">>> Habilitando servicios (requiere sudo)..."
# sudo systemctl enable tlp.service # Descomenta si quieres activar TLP
# sudo systemctl enable bluetooth.service # Descomenta si quieres activar Bluetooth al inicio


echo ">>> ¡Configuración inicial completada!"
echo ">>> Recuerda reiniciar o recargar i3 ($mod+Shift+r o $mod+Shift+c) si has cambiado configuraciones activas."
echo ">>> Puede que necesites reiniciar el sistema para que algunos servicios/cambios surtan efecto."

exit 0
