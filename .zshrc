# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt autocd beep extendedglob nomatch notify
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/jmro/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in 
*":$PNPM_HOME/bin:"*) ;;
*) export  PATH="$PNPM_HOME/bin:$PATH" ;;
esac

# Dotfiles management
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
