# --- Manjaro ZSH Configuration ---
# This file is sourced by Zsh. If sourced by others, it should stay silent.

if [ -n "$ZSH_VERSION" ]; then
    # Source manjaro-zsh-configuration
    [[ -e /usr/share/zsh/manjaro-zsh-config ]] && source /usr/share/zsh/manjaro-zsh-config
    [[ -e /usr/share/zsh/manjaro-zsh-prompt ]] && source /usr/share/zsh/manjaro-zsh-prompt

    # Basic Options
    HISTFILE=~/.histfile
    HISTSIZE=10000
    SAVEHIST=10000
    setopt autocd beep extendedglob nomatch notify
    bindkey -e

    # --- Modular Custom Configurations ---
    ZSH_CONFIG_DIR="$HOME/.config/zsh"

    # 1. Load Functions (Recursive)
    if [ -d "$ZSH_CONFIG_DIR/functions" ]; then
        # Use find to be compatible with basic shell parsing
        # but source each file into the current Zsh session.
        # We exclude .sh files (standalone scripts).
        while read -r func; do
            source "$func"
        done <<EOF
$(find "$ZSH_CONFIG_DIR/functions" -type f ! -name "*.sh")
EOF
    fi

    # 2. Load Git Scripts
    if [ -d "$ZSH_CONFIG_DIR/git-scripts" ]; then
        while read -r script; do
            source "$script"
        done <<EOF
$(find "$ZSH_CONFIG_DIR/git-scripts" -type f -name "*.zsh")
EOF
    fi

    # 3. Load Aliases and other modular files
    [ -f "$ZSH_CONFIG_DIR/options.zsh" ] && source "$ZSH_CONFIG_DIR/options.zsh"
    [ -f "$ZSH_CONFIG_DIR/aliases.zsh" ] && source "$ZSH_CONFIG_DIR/aliases.zsh"
    [ -f "$ZSH_CONFIG_DIR/keybindings.zsh" ] && source "$ZSH_CONFIG_DIR/keybindings.zsh"

fi

# --- Global Environment (Safe for all shells) ---
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in 
*":$PNPM_HOME/bin:"*) ;;
*) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac

# Dotfiles management
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
