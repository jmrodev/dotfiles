# --- Manjaro ZSH Configuration ---
if [ -n "$ZSH_VERSION" ]; then
    [[ -e /usr/share/zsh/manjaro-zsh-config ]] && source /usr/share/zsh/manjaro-zsh-config
    [[ -e /usr/share/zsh/manjaro-zsh-prompt ]] && source /usr/share/zsh/manjaro-zsh-prompt

    # Basic Options
    setopt autocd beep extendedglob nomatch notify
    bindkey -e

    # Load custom aliases directly (avoiding complex loops for now)
    [ -f "$HOME/.config/zsh/aliases.zsh" ] && source "$HOME/.config/zsh/aliases.zsh"
fi

# Global Environment
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME/bin:$PATH"

alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Welcome message
if [ -n "$ZSH_VERSION" ]; then
    echo -e "\n\033[0;33m💡 Tip: Escribe \033[1;32mdot-help\033[0;33m para ver tus comandos.\033[0m"
fi


# Added by Antigravity CLI installer
export PATH="/home/jmro/.local/bin:$PATH"

# Theme settings for Qt6 / Qt5 dark mode
export QT_QPA_PLATFORMTHEME=qt6ct
