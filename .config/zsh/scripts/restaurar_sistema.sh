#!/bin/bash

# ==============================================================================
# Script de Restauración Definitiva - Manjaro KDE (Fer Edition)
# Version: 2.6 (Sincronizado con Estilo Rainbow + ZRAM)
# ==============================================================================

set -e 

# === CONFIGURACIÓN DE CREDENCIALES (Cámbialas aquí) ===
TRELLO_API_KEY="${TRELLO_API_KEY:-98a2e6ccb8ff7c48a650d08ad30a5f9e}"
TRELLO_TOKEN="${TRELLO_TOKEN:-ATTA6b1abe166cdab12a57e042b71934823c99360573edacf223a336b6d5490885297D642EFB}"

echo "--- 1. Optimizando Mirrors y Actualizando Sistema ---"
sudo pacman-mirrors -f 5
sudo pacman -Syu --noconfirm

echo "--- 1.1. Optimización Avanzada de Memoria (ZRAM + Kernel Ratios) ---"
sudo pacman -S --noconfirm zram-generator
cat <<EOF | sudo tee /etc/systemd/zram-generator.conf
[zram0]
zram-size = ram
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
EOF
cat <<EOF | sudo tee /etc/sysctl.d/99-performance.conf
vm.swappiness = 180
vm.vfs_cache_pressure = 50
vm.dirty_background_ratio = 5
vm.dirty_ratio = 15
vm.page-cluster = 0
EOF
sudo systemctl daemon-reload
sudo systemctl start /dev/zram0
sudo sysctl --system

echo "--- 1.2. Estabilidad de Red (Wifi Realtek RTL8723DE) ---"
# Soluciona desconexiones constantes desactivando ahorro de energía profundo y ASPM
cat <<EOF | sudo tee /etc/modprobe.d/rtw88.conf
options rtw88_core disable_lps_deep=Y
options rtw88_pci disable_aspm=Y
EOF
# Desactivar ahorro de energía de NetworkManager
sudo mkdir -p /etc/NetworkManager/conf.d/
cat <<EOF | sudo tee /etc/NetworkManager/conf.d/default-wifi-powersave-on.conf
[connection]
wifi.powersave = 2
EOF

echo "--- 2. Instalando Software Base y Pack Pro ---"
sudo pacman -S --needed --noconfirm \
    base-devel git curl wget zsh net-tools nmap wireguard-tools \
    nodejs-lts-jod npm yarn jdk-openjdk go dotnet-sdk \
    python python-pip \
    ripgrep fd fzf zoxide bat eza \
    mpv ranger htop fastfetch \
    btop tldr micro lazygit \
    intel-media-driver \
    docker docker-compose \
    github-cli neovim dolphin-plugins

echo "--- 3. Instalando yay (AUR Helper) ---"
if ! command -v yay &> /dev/null; then
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd -
else
    echo "yay ya está instalado."
fi

echo "--- 4. Software desde AUR (yay) ---"
yay -S --needed --noconfirm \
    google-chrome rustdesk-bin \
    antigravity \
    postman-bin \
    genymotion \
    slack-desktop \
    auto-cpufreq \
    trello-cli \
    ttf-meslo-nerd-font-powerlevel10k \
    openjdk-common-bin \
    zapzap

echo "--- 4.1. Herramientas Globales de Node.js ---"
sudo npm install -g @google/gemini-cli
# Servidores MCP para Gemini CLI
sudo npm install -g @modelcontextprotocol/server-filesystem @modelcontextprotocol/server-github @modelcontextprotocol/server-postgres @delorenj/mcp-server-trello

# Configuración automática de servidores MCP en Gemini CLI
gemini mcp add trello npx -y @delorenj/mcp-server-trello --env TRELLO_API_KEY="$TRELLO_API_KEY" --env TRELLO_TOKEN="$TRELLO_TOKEN" --level global

echo "--- 5. Configurando ZSH y Oh My Zsh ---"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ] && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
[ ! -d "$ZSH_CUSTOM/plugins/zsh-autocomplete" ] && git clone https://github.com/marlonrichert/zsh-autocomplete.git "$ZSH_CUSTOM/plugins/zsh-autocomplete"
[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
[ ! -d "$ZSH_CUSTOM/plugins/fast-syntax-highlighting" ] && git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git "$ZSH_CUSTOM/plugins/fast-syntax-highlighting"

echo "--- 7. Restaurando configuración .zshrc PERSONALIZADA ---"
ZSHRC="$HOME/.zshrc"

if grep -q "source \"\$HOME/.config/zsh/.zshrc\"" "$ZSHRC" 2>/dev/null; then
    echo "Tu .zshrc ya es modular. Saltando escritura para no romper la estructura del repo."
else
    [ -f "$ZSHRC" ] && cp "$ZSHRC" "$ZSHRC.bak"

cat <<'EOT' > "$ZSHRC"
# ~/.zshrc (Entry Point)
# This file is managed by the dotfiles bare repository.
# The actual configuration lives in ~/.config/zsh/.zshrc

source "$HOME/.config/zsh/.zshrc"
EOT
fi

echo "--- 8. Restaurando configuración VISUAL ACTUAL (.p10k.zsh) ---"
# ... (resto del código de restauración visual igual hasta la sección 8.2)

echo "--- 8.2. Configuración de Energía (Systemd + auto-cpufreq) ---"
# Desactivar suspensión al cerrar la tapa a nivel de sistema (Logind)
sudo sed -i 's/^#HandleLidSwitch=.*/HandleLidSwitch=ignore/' /etc/systemd/logind.conf
sudo sed -i 's/^#HandleLidSwitchExternalPower=.*/HandleLidSwitchExternalPower=ignore/' /etc/systemd/logind.conf
sudo sed -i 's/^#HandleLidSwitchDocked=.*/HandleLidSwitchDocked=ignore/' /etc/systemd/logind.conf
sudo sed -i 's/^#LidSwitchIgnoreInhibited=.*/LidSwitchIgnoreInhibited=yes/' /etc/systemd/logind.conf

if command -v auto-cpufreq &> /dev/null; then
    # Usar el instalador propio de auto-cpufreq para asegurar que los servicios se configuren bien
    sudo auto-cpufreq --install > /dev/null
    sudo systemctl disable --now power-profiles-daemon 2>/dev/null || true
fi

# Aplicar cambios de logind sin reiniciar el servicio (evita cerrar sesión)
sudo systemctl kill -s SIGHUP systemd-logind

echo "--- 9. Finalización ---"
# Configuración final de Docker
if command -v docker &> /dev/null; then
    sudo systemctl enable --now docker
    sudo usermod -aG docker "$USER"
    echo "Docker configurado (recuerda reiniciar sesión para los permisos de grupo)."
fi

tldr --update

echo "--- 9.1. Configuración de Trello CLI ---"
if command -v trello &> /dev/null; then
    while true; do
        echo "----------------------------------------------------"
        echo "CONFIGURACIÓN DE TRELLO"
        read -p "¿Deseas usar las credenciales por defecto? (S/n): " usar_defecto
        
        if [[ "$usar_defecto" =~ ^[Nn]$ ]]; then
            read -p "Ingresa tu Trello API Key: " T_KEY
            read -sp "Ingresa tu Trello Token: " T_TOKEN
            echo -e "\nVerificando..."
        else
            T_KEY="${TRELLO_API_KEY}"
            T_TOKEN="${TRELLO_TOKEN}"
            echo "Verificando credenciales por defecto..."
        fi

        # Configurar temporalmente
        trello auth:api-key "$T_KEY" &> /dev/null
        trello auth:token "$T_TOKEN" &> /dev/null

        # Probar conexión real pegando a la API
        if trello board:list &> /dev/null; then
            echo "✅ ¡Acceso verificado correctamente!"
            trello sync
            break # Salir del bucle porque todo está bien
        else
            echo "❌ ERROR: No se pudo conectar a Trello con esos datos."
            echo "Asegúrate de que la Key y el Token sean correctos."
            echo "Intentémoslo de nuevo..."
        fi
    done
fi

echo "¡Script sincronizado con tu nuevo Estilo Visual y Optimizaciones!"

echo "--- 10. Configurando SSH Config para Raspberry Pi ---"
mkdir -p ~/.ssh
cat <<EOT >> ~/.ssh/config

Host rpi
    HostName 192.168.1.11
    User cima
    Port 2222
    IdentityFile ~/.ssh/id_ed25519

Host rpi-ext
    HostName jmro.duckdns.org
    User cima
    Port 2222
    IdentityFile ~/.ssh/id_ed25519
EOT
chmod 600 ~/.ssh/config
