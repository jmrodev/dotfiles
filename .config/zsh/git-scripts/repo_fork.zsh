#!/bin/zsh
echo -n "URL del repo a forkar (q para cancelar): "
read repourl
[[ "$repourl" == "q" || -z "$repourl" ]] && echo "Acción cancelada." && exit 1
gh repo fork "$repourl" --clone=true
