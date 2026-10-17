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

# OpenCode Config
set -gx OPENCODE_EXPERIMENTAL true

# ==========================================
# Aliases y Herramientas Modernas
# ==========================================
alias ls 'eza --icons=always --color=always --group-directories-first'
alias ll 'eza -alF --icons=always --color=always --group-directories-first --header --git'
alias tree 'eza --tree --icons=always'
alias cat 'bat --style=plain'
alias man 'batman'

# Server and PBX helpers are standalone scripts in ~/.local/bin (server-on, server-off, pbx-on, pbx-off)

# Alias de Dotfiles Bare Repo
alias dotfiles '/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias menu 'cheatsheet'

# ==========================================
# Inicializaciones Automáticas
# ==========================================
if command -v zoxide >/dev/null 2>&1
    zoxide init fish | source
    alias cd z
end

function jupyter -d "Inicia JupyterLab en ~/Notebooks"
    mkdir -p ~/Notebooks
    jupyter-lab ~/Notebooks
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
    # Inicio limpio sin banners
end

