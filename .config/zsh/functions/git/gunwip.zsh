# ~/.config/zsh/functions/git/gunwip.zsh
# gunwip
# Deshace el último commit, pero mantiene los cambios en el área de staging.
gunwip() {
  git reset --soft HEAD^
}
