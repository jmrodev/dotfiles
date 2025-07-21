#!/bin/zsh
issue_id=$(gh issue list | fzf --prompt="Selecciona Issue para cerrar: " | awk '{print $1}')
[[ -z "$issue_id" ]] && echo "No se seleccionó ningún Issue." && exit 1
gh issue close "$issue_id" && echo "Issue cerrado." 