# ~/.config/zsh/functions/ff.zsh

# Buscar archivos por nombre
function ff() {
    find . -type f -iname "*$**" -ls
}
