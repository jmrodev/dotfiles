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
alias recolectar '~/coleccion_comandos/recolectar.sh'

alias cat 'bat --style=plain'
alias man 'batman'

alias pi-local "pi --provider ollama --model qwen2.5-coder:7b"
alias pi-cloud "pi --provider google --model gemini-3.1-pro-preview"

# Aliases de Servidor
function server-off
    echo "=> Intentando apagar servidor (192.168.50.10)..."
    if ssh -o ConnectTimeout=3 -t jmro@192.168.50.10 "sudo poweroff"
        set_color green; echo "[OK] Orden de apagado enviada correctamente."; set_color normal
    else
        set_color red; echo "[ERROR] SSH falló. El servidor no responde o la IP está mal."; set_color normal
        return 1
    end
end

alias server-on 'wakeonlan 00:25:64:e2:bf:4b'

function pbx-on
    echo "=> Iniciando stack VoIP..."
    if ssh -o ConnectTimeout=3 -t jmro@192.168.50.10 "docker compose -f ~/voip-stack/compose.yml start"
        set_color green; echo "[OK] PBX iniciada."; set_color normal
    else
        set_color red; echo "[ERROR] Falló la conexión al servidor para iniciar PBX."; set_color normal
        return 1
    end
end

function pbx-off
    echo "=> Deteniendo stack VoIP..."
    if ssh -o ConnectTimeout=3 -t jmro@192.168.50.10 "docker compose -f ~/voip-stack/compose.yml stop"
        set_color green; echo "[OK] PBX detenida."; set_color normal
    else
        set_color red; echo "[ERROR] Falló la conexión al servidor para detener PBX."; set_color normal
        return 1
    end
end

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
# Tmux Autostart y Greeting (Banner 2 Col)
# ==========================================
if status is-interactive
    if test -z "$TMUX"
        exec tmux new-session -A -s main
    end
end

function fish_greeting
    if test -n "$TMUX"
        echo -e "\033[38;5;111m╭─────────────────────────────────── \033[1;38;5;111mSYSTEM CHEATSHEET & DASHBOARD\033[0m\033[38;5;111m ───────────────────────────────────╮\033[0m"
        echo -e "\033[38;5;111m│\033[0m  \033[1;38;5;214m⚡ SWAY & NAVEGACIÓN\033[0m              \033[38;5;111m│\033[0m  \033[1;38;5;214m🖥️ SERVICIOS & ALIAS\033[0m             \033[38;5;111m│\033[0m"
        echo -e "\033[38;5;111m│\033[0m  \033[38;5;114mSuper + i    \033[0m Chrome Workspace    \033[38;5;111m│\033[0m  \033[38;5;114mserver-on/off\033[0m Servidor WOL / SSH   \033[38;5;111m│\033[0m"
        echo -e "\033[38;5;111m│\033[0m  \033[38;5;114mSuper + Enter\033[0m Terminal Kitty      \033[38;5;111m│\033[0m  \033[38;5;114mpbx-on/off   \033[0m VoIP Docker Stack    \033[38;5;111m│\033[0m"
        echo -e "\033[38;5;111m│\033[0m  \033[38;5;114mSuper + d    \033[0m Menú de Apps        \033[38;5;111m│\033[0m  \033[38;5;114mgns3         \033[0m Redes & Emulador     \033[38;5;111m│\033[0m"
        echo -e "\033[38;5;111m│\033[0m  \033[38;5;114mSuper + Shift+q\033[0m Cerrar Ventana    \033[38;5;111m│\033[0m  \033[38;5;114mll / tree    \033[0m Eza Git / Árbol      \033[38;5;111m│\033[0m"
        echo -e "\033[38;5;111m│\033[0m  \033[38;5;114mSuper + [1..9]\033[0m Ir a Workspace N   \033[38;5;111m│\033[0m  \033[38;5;114mcat / man    \033[0m Bat / Batman viewer  \033[38;5;111m│\033[0m"
        echo -e "\033[38;5;111m├────────────────────────────────────┼────────────────────────────────────┤\033[0m"
        echo -e "\033[38;5;111m│\033[0m  \033[1;38;5;214m⌨️ TMUX CONTROL (Prefix: C-a)\033[0m     \033[38;5;111m│\033[0m  \033[1;38;5;214m🤖 AI & BOT SHORTCUTS\033[0m            \033[38;5;111m│\033[0m"
        echo -e "\033[38;5;111m│\033[0m  \033[38;5;114mC-a + v / s  \033[0m Div Vert / Horiz    \033[38;5;111m│\033[0m  \033[38;5;114mpi-local     \033[0m Ollama Qwen2.5 7B   \033[38;5;111m│\033[0m"
        echo -e "\033[38;5;111m│\033[0m  \033[38;5;114mC-a + h/j/k/l\033[0m Moverse Panel       \033[38;5;111m│\033[0m  \033[38;5;114mpi-cloud     \033[0m Gemini 3.1 Pro      \033[38;5;111m│\033[0m"
        echo -e "\033[38;5;111m│\033[0m  \033[38;5;114mC-a + c / x  \033[0m Nueva Ventana/Cerrar\033[38;5;111m│\033[0m  \033[38;5;114mdotfiles     \033[0m Git Bare Repository \033[38;5;111m│\033[0m"
        echo -e "\033[38;5;111m│\033[0m  \033[38;5;114mC-a + f      \033[0m Tmux Sessionizer    \033[38;5;111m│\033[0m  \033[38;5;114mz <directorio>\033[0m Navegación Zoxide   \033[38;5;111m│\033[0m"
        echo -e "\033[38;5;111m╰────────────────────────────────────┴────────────────────────────────────╯\033[0m"
    end
end
