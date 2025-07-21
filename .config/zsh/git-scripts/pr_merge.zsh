#!/bin/zsh
pr_id=$(gh pr list | fzf --prompt="Selecciona PR para mergear: " | awk '{print $1}')
[[ -z "$pr_id" ]] && echo "No se seleccionó ningún PR." && exit 1
gh pr merge "$pr_id" 