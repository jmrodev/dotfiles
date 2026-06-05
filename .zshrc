# Manjaro ZSH Configuration
# Source manjaro-zsh-configuration
if [[ -e /usr/share/zsh/manjaro-zsh-config ]]; then
  source /usr/share/zsh/manjaro-zsh-config
fi

# Use manjaro zsh prompt
if [[ -e /usr/share/zsh/manjaro-zsh-prompt ]]; then
  source /usr/share/zsh/manjaro-zsh-prompt
fi

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt autocd beep extendedglob nomatch notify
bindkey -e
# End of lines configured by zsh-newuser-install

# Custom Environment Variables
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in 
*":$PNPM_HOME/bin:"*) ;;
*) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac

# --- Custom Configurations ---
ZSH_CONFIG_DIR="$HOME/.config/zsh"

# Load modular configs
[[ -f "$ZSH_CONFIG_DIR/options.zsh" ]] && source "$ZSH_CONFIG_DIR/options.zsh"
[[ -f "$ZSH_CONFIG_DIR/aliases.zsh" ]] && source "$ZSH_CONFIG_DIR/aliases.zsh"
[[ -f "$ZSH_CONFIG_DIR/keybindings.zsh" ]] && source "$ZSH_CONFIG_DIR/keybindings.zsh"

# Load all functions
if [[ -d "$ZSH_CONFIG_DIR/functions" ]]; then
    for func in "$ZSH_CONFIG_DIR"/functions/**/*(N-.); do
        source "$func"
    done
fi

# Load Git scripts
if [[ -d "$ZSH_CONFIG_DIR/git-scripts" ]]; then
    for script in "$ZSH_CONFIG_DIR"/git-scripts/*.zsh(N-.); do
        source "$script"
    done
fi

# Dotfiles management
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
