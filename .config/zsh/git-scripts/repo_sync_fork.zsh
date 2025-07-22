#!/bin/zsh
echo -n "Nombre del repo fork (owner/repo, q para cancelar): "
read repofork
[[ "$repofork" == "q" || -z "$repofork" ]] && echo "Acción cancelada." && exit 1
gh repo sync "$repofork" && echo "Fork sincronizado." 