# ==========================================
# Configuración Core de Zsh (Manjaro Base)
# ==========================================
if [[ -e /usr/share/zsh/manjaro-zsh-config ]]; then
  source /usr/share/zsh/manjaro-zsh-config
fi

# Activar historial de autocompletado (zsh-autosuggestions)
if [[ -e /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# ==========================================
# Aliases y Herramientas Modernas
# ==========================================
# Eza: El reemplazo moderno de ls (escrito en Rust)
alias ls='eza --icons=always --color=always --group-directories-first'
alias ll='eza -alF --icons=always --color=always --group-directories-first --header --git'
alias tree='eza --tree --icons=always'

# Bat: El reemplazo de cat con syntax highlighting
alias cat='bat --style=plain'
alias man='batman'

# Zoxide: El reemplazo inteligente de cd
eval "$(zoxide init zsh)"
alias cd='z'

# ==========================================
# Inicialización del Prompt (Starship)
# ==========================================
eval "$(starship init zsh)"

# fzf setup
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi


export PATH="$HOME/.opencode/bin:$HOME/.local/bin:$HOME/.npm-global/bin:$HOME/go/bin:$PATH"

# ==========================================
# AI Agents API Keys (Gemini / Google)
# ==========================================
source ~/.zsh_secrets
export NVIDIA_API_KEY=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

# ==========================================
# Ollama & OpenCode Config
# ==========================================
export OLLAMA_NUM_CTX=8192
export OLLAMA_MAX_LOADED_MODELS=2
export OPENCODE_EXPERIMENTAL=true

alias pi-local="pi --provider ollama --model qwen2.5-coder:7b"
alias pi-cloud="pi --provider google --model gemini-3.1-pro-preview"

# ==========================================
# Aliases de Operativa de Servidor (Debian)
# ==========================================

# Gestión Física (Hardware)
alias server-off='ssh -t jmro@192.168.1.34 "sudo poweroff"'
alias server-on='wakeonlan 00:25:64:e2:bf:4b'

# Gestión del PBX (Asterisk en Docker)
alias pbx-on='ssh -t jmro@192.168.1.34 "docker compose -f ~/voip-stack/compose.yml start"'
alias pbx-off='ssh -t jmro@192.168.1.34 "docker compose -f ~/voip-stack/compose.yml stop"'


# Android SDK Environment Variables
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export _JAVA_AWT_WM_NONREPARENTING=1



# Added by Antigravity CLI installer
export PATH="/home/jmro/.local/bin:$PATH"

alias limpieza='orphans=$(pacman -Qdtq 2>/dev/null); if [ -n "$orphans" ]; then sudo pacman -Rns $orphans --noconfirm; else echo "No hay paquetes huérfanos."; fi; sudo paccache -r -k2; sudo journalctl --vacuum-time=7d; flatpak uninstall --unused -y || true; [ -n "$ZSH_VERSION" ] && unsetopt RM_STAR_SILENT RM_STAR_WAIT; if [ -d "$HOME/.cache" ]; then echo "Eliminando archivos de caché…"; find "$HOME/.cache" -type f -print -delete; echo "Eliminando directorios de caché vacíos…"; find "$HOME/.cache" -type d -empty -print -delete; fi; echo "Limpieza del sistema completada."'
export PATH="$HOME/.local/bin:$PATH"

# ==========================================
# Tmux Autostart
# ==========================================
# Si abrimos una terminal interactiva y no estamos dentro de Tmux,
# conectarse a la sesión "main" (o crearla si no existe) y reemplazar Zsh.
if [[ -z "$TMUX" ]] && [[ -n "$PS1" ]]; then
    exec tmux new-session -A -s main
fi
source ~/.tmux_banner.sh
