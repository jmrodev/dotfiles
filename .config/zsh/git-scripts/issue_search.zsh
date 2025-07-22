#!/bin/zsh
echo -n "Palabra clave para buscar issues: "
read keyword
[[ "$keyword" == "q" || -z "$keyword" ]] && echo "Acción cancelada." && exit 1
gh issue list --search "$keyword" | less 