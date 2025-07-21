#!/bin/zsh
echo -n "Nombre del repo (owner/repo, q para cancelar): "
read repodel
[[ "$repodel" == "q" || -z "$repodel" ]] && echo "Acción cancelada." && exit 1
gh repo delete "$repodel" --confirm
