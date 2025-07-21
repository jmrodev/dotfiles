#!/bin/zsh
echo -n "Título del issue: "
read title
[[ "$title" == "q" || -z "$title" ]] && echo "Acción cancelada." && exit 1
echo -n "Descripción: "
read desc
gh issue create --title "$title" --body "$desc" 