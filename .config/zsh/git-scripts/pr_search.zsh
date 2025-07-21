#!/bin/zsh
echo -n "Palabra clave para buscar PRs: "
read keyword
[[ "$keyword" == "q" || -z "$keyword" ]] && echo "Acción cancelada." && exit 1
gh pr list --search "$keyword" | less 