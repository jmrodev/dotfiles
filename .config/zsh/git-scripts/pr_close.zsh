#!/bin/zsh
pr_id=$(gh pr list | fzf --prompt="Selecciona PR para cerrar: " | awk '{print $1}')
[[ -z "$pr_id" ]] && echo "No se seleccionó ningún PR." && exit 1
gh pr close "$pr_id" && echo "PR cerrado." 