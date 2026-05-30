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
sudo pacman -S --noconfirm \
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
yay -S --noconfirm \
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
[ -f "$ZSHRC" ] && cp "$ZSHRC" "$ZSHRC.bak"

cat <<'EOT' > "$ZSHRC"
# === CARGA DE FASTFETCH ===
fastfetch

# Enable Powerlevel10k instant prompt.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# === CONFIGURACION BASE ZSH ===
HISTFILE=~/.histfile
HISTSIZE=50000
SAVEHIST=50000
setopt autocd beep extendedglob nomatch notify
bindkey -e

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git sudo z zsh-autosuggestions fast-syntax-highlighting zsh-autocomplete archlinux extract web-search copyfile dirhistory
)

source $ZSH/oh-my-zsh.sh

# === ALIAS DE SEGURIDAD ===
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

# === ALIAS DE DESARROLLO ===
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias edit='nvim'

# === GESTION DE PAQUETES ===
alias update='yay -Syyyu --noconfirm'
alias actualizar='yay -Syyyu --noconfirm'
alias install='yay -S'
alias remove='yay -Rns'
alias pacclean='sudo pacman -Rns $(pacman -Qdtq)'

# === FUNCIONES ===
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# === CONFIGURACION DE AUTOCOMPLETADO ===
zstyle ':autocomplete:*' delay 0.8
zstyle ':autocomplete:*' list-lines 10
zstyle ':autocomplete:tab:*' insert-unambiguous yes
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%B%F{yellow}-- %d --%f%b'
zstyle ':completion:*' tag-order 'aliases' 'functions' 'commands' 'builtins' 'local-directories' 'directories' 'files'
zstyle ':completion:*' group-order aliases functions commands builtins local-directories directories files
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' verbose yes

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

alias ls='eza --color=always --group-directories-first --icons'
alias ll='eza -lah --color=always --group-directories-first --icons'
alias la='eza -a --icons'
alias lla='eza -la --icons --git'
alias lt='eza --tree --level=2 --icons'
alias cat='bat --paging=never --style=plain'
alias top='btop'
alias lg='lazygit'
alias rpi='ssh rpi'
alias rpi-ext='ssh rpi-ext'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

eval "$(zoxide init zsh)"
source <(fzf --zsh)

# === ALIAS DE RENDIMIENTO PERMANENTE ===
# Configura el sistema para rendimiento máximo y asegura que la tapa sea ignorada sin cerrar sesión
alias fullpower='sudo systemctl kill -s SIGHUP systemd-logind && sudo auto-cpufreq --stats && echo "Sistema optimizado por auto-cpufreq y Tapa Ignorada (SIGHUP enviado)."'

[[ -f ~/.config/pnpm/env ]] && source ~/.config/pnpm/env
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOT

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
