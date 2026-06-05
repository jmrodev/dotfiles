# --- Dotfiles Entry Point (i3wm Branch) ---
if [ -n "$ZSH_VERSION" ]; then
    source "$HOME/.config/zsh/.zshrc"
fi

# Global environment (Safe for all)
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in 
*":$PNPM_HOME/bin:"*) ;;
*) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac

# Dotfiles management
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
