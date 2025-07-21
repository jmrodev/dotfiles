#!/bin/zsh
issue_id=$(gh issue list | fzf --prompt="Selecciona Issue para editar: " | awk '{print $1}')
[[ -z "$issue_id" ]] && echo "No se seleccionó ningún Issue." && exit 1
gh issue edit "$issue_id" 