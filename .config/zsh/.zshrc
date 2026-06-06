# --- Manjaro ZSH Configuration ---
if [ -n "$ZSH_VERSION" ]; then
    # Source manjaro-zsh-configuration
    [[ -e /usr/share/zsh/manjaro-zsh-config ]] && source /usr/share/zsh/manjaro-zsh-config
    [[ -e /usr/share/zsh/manjaro-zsh-prompt ]] && source /usr/share/zsh/manjaro-zsh-prompt

    # Basic Options
    setopt autocd beep extendedglob nomatch notify
    bindkey -e

    ZSH_CONFIG_DIR="$HOME/.config/zsh"

    # 1. Load Functions (Safe way for all parsers)
    if [ -d "$ZSH_CONFIG_DIR/functions" ]; then
        # Use a temporary file to avoid pipe subshells
        _func_list=$(find "$ZSH_CONFIG_DIR/functions" -type f ! -name "*.sh")
        while read -r func; do
            [ -f "$func" ] && source "$func"
        done <<EOF
$_func_list
EOF
        unset _func_list
    fi

    # 2. Load Git Scripts
    if [ -d "$ZSH_CONFIG_DIR/git-scripts" ]; then
        _script_list=$(find "$ZSH_CONFIG_DIR/git-scripts" -type f -name "*.zsh")
        while read -r script; do
            [ -f "$script" ] && source "$script"
        done <<EOF
$_script_list
EOF
        unset _script_list
    fi

    # 3. Load Aliases and modular files
    [ -f "$ZSH_CONFIG_DIR/options.zsh" ] && source "$ZSH_CONFIG_DIR/options.zsh"
    [ -f "$ZSH_CONFIG_DIR/aliases.zsh" ] && source "$ZSH_CONFIG_DIR/aliases.zsh"
    [ -f "$ZSH_CONFIG_DIR/keybindings.zsh" ] && source "$ZSH_CONFIG_DIR/keybindings.zsh"

fi

# --- Global Environment ---
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME/bin:$PATH"

alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Welcome message
if [ -n "$ZSH_VERSION" ]; then
    if typeset -f dot-help > /dev/null; then
        echo -e "\n\033[0;33m💡 Tip: Escribe \033[1;32mdot-help\033[0;33m para ver tus comandos.\033[0m"
    else
        # Final emergency source if everything else failed
        [ -f "$HOME/.config/zsh/aliases.zsh" ] && source "$HOME/.config/zsh/aliases.zsh"
        echo -e "\n\033[0;33m💡 Tip: Escribe \033[1;32mdot-help\033[0;33m para ver tus comandos.\033[0m"
    fi
fi
