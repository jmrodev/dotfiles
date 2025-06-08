# ~/.config/zsh/functions/git/gwip.zsh
# gwip
# Añade todos los cambios y hace un commit con el mensaje "WIP"
gwip() {
  git add -A && git commit -m "WIP"
}
