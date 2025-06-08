# ~/.config/zsh/functions/git/dotfiles_current_branch.zsh
# Asume que tienes un alias 'dotfiles' definido como:
# alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
dotfiles_current_branch() {
  if alias command dotfiles &> /dev/null; then
    command dotfiles rev-parse --abbrev-ref HEAD 2>/dev/null
  else
    echo "Error: El alias 'dotfiles' no está definido." >&2
    return 1
  fi
}
