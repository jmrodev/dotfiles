#!/bin/zsh
echo -n "Nombre del repo (owner/repo, q para cancelar): "
read repoview
[[ "$repoview" == "q" || -z "$repoview" ]] && echo "Acción cancelada." && exit 1
gh repo view "$repoview" --web 