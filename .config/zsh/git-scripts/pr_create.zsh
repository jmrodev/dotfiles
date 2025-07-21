#!/bin/zsh
echo -n "Título del PR: "
read title
[[ "$title" == "q" || -z "$title" ]] && echo "Acción cancelada." && exit 1
echo -n "Descripción: "
read desc
gh pr create --title "$title" --body "$desc" 