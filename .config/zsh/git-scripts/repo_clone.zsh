#!/bin/zsh
echo -n "URL del repo a clonar (q para cancelar): "
read repourl
[[ "$repourl" == "q" || -z "$repourl" ]] && echo "Acción cancelada." && exit 1
gh repo clone "$repourl"
