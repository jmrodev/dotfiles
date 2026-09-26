# ==========================================
# Configuración Core de Fish
# ==========================================

# Variables de entorno y PATH
fish_add_path $HOME/.opencode/bin
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.npm-global/bin
fish_add_path $HOME/go/bin

# Android SDK
set -gx ANDROID_HOME $HOME/Android/Sdk
fish_add_path $ANDROID_HOME/emulator
fish_add_path $ANDROID_HOME/platform-tools
set -gx _JAVA_AWT_WM_NONREPARENTING 1

# Ollama & OpenCode Config
set -gx OLLAMA_NUM_CTX 8192
set -gx OLLAMA_MAX_LOADED_MODELS 2
set -gx OPENCODE_EXPERIMENTAL true

# ==========================================
# Aliases y Herramientas Modernas
# ==========================================
alias ls 'eza --icons=always --color=always --group-directories-first'
alias ll 'eza -alF --icons=always --color=always --group-directories-first --header --git'
alias tree 'eza --tree --icons=always'

alias cat 'bat --style=plain'
alias man 'batman'

alias pi-local "pi --provider ollama --model qwen2.5-coder:7b"
alias pi-cloud "pi --provider google --model gemini-3.1-pro-preview"

# Aliases de Servidor
alias server-off 'ssh -t jmro@192.168.1.34 "sudo poweroff"'
alias server-on 'wakeonlan 00:25:64:e2:bf:4b'
alias pbx-on 'ssh -t jmro@192.168.1.34 "docker compose -f ~/voip-stack/compose.yml start"'
alias pbx-off 'ssh -t jmro@192.168.1.34 "docker compose -f ~/voip-stack/compose.yml stop"'

# Alias de Dotfiles Bare Repo
alias dotfiles '/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# ==========================================
# Inicializaciones Automáticas
# ==========================================
if command -v zoxide >/dev/null 2>&1
    zoxide init fish | source
    alias cd z
end

if command -v starship >/dev/null 2>&1
    starship init fish | source
end

if command -v fzf >/dev/null 2>&1
    fzf --fish | source
end

# ==========================================
# Tmux Autostart y Greeting (Banner)
# ==========================================
if status is-interactive
    if test -z "$TMUX"
        exec tmux new-session -A -s main
    end
end

function fish_greeting
    if test -n "$TMUX"
        echo -e "\033[38;5;111m╭───────────────── \033[1;38;5;111mTmux Cheatsheet (Prefix: C-a)\033[0m\033[38;5;111m ───────────────╮\033[0m"
        echo -e "\033[38;5;111m│\033[0m  \033[38;5;114mC-a + v      \033[0m Div. Vertical  \033[38;5;111m│\033[0m \033[38;5;114mC-a + s      \033[0m Div. Horizontal \033[38;5;111m│\033[0m"
        echo -e "\033[38;5;111m│\033[0m  \033[38;5;114mC-a + h/j/k/l\033[0m Moverse        \033[38;5;111m│\033[0m \033[38;5;114mC-h/j/k/l    \033[0m Moverse rápido  \033[38;5;111m│\033[0m"
        echo -e "\033[38;5;111m│\033[0m  \033[38;5;114mC-a + H/J/K/L\033[0m Tamaño         \033[38;5;111m│\033[0m \033[38;5;114mC-a + f      \033[0m Sessionizer     \033[38;5;111m│\033[0m"
        echo -e "\033[38;5;111m│\033[0m  \033[38;5;114mMouse        \033[0m Seleccionar    \033[38;5;111m│\033[0m \033[38;5;114mMid Click    \033[0m Pegar           \033[38;5;111m│\033[0m"
        echo -e "\033[38;5;111m│\033[0m  \033[38;5;114mC-a + x      \033[0m Cerrar Panel   \033[38;5;111m│\033[0m \033[38;5;114mC-a + &      \033[0m Matar Ventana   \033[38;5;111m│\033[0m"
        echo -e "\033[38;5;111m│\033[0m  \033[38;5;114mC-a + c      \033[0m Nueva Ventana  \033[38;5;111m│\033[0m \033[38;5;114mC-a + n/p    \033[0m Cambiar Ventana \033[38;5;111m│\033[0m"
        echo -e "\033[38;5;111m│\033[0m  \033[38;5;114mC-a + { / }  \033[0m Intercambiar   \033[38;5;111m│\033[0m \033[38;5;114mC-a + o      \033[0m Rotar Paneles   \033[38;5;111m│\033[0m"
        echo -e "\033[38;5;111m│\033[0m  \033[38;5;114mC-a + [      \033[0m Modo Copia     \033[38;5;111m│\033[0m \033[38;5;114mv / y o Enter\033[0m Selec / Copiar  \033[38;5;111m│\033[0m"
        echo -e "\033[38;5;111m╰───────────────────────────────────────────────────────────────╯\033[0m"
    end
end
