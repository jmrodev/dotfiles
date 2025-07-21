#!/bin/zsh
gist_id=$(gh gist list | fzf --prompt="Selecciona Gist para editar: " | awk '{print $1}')
[[ -z "$gist_id" ]] && echo "No se seleccionó ningún Gist." && exit 1
gh gist edit "$gist_id"
