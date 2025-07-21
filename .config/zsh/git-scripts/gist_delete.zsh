#!/bin/zsh
gist_id=$(gh gist list | fzf --prompt="Selecciona Gist para borrar: " | awk '{print $1}')
[[ -z "$gist_id" ]] && echo "No se seleccionó ningún Gist." && exit 1
gh gist delete "$gist_id" && echo "Gist borrado."
