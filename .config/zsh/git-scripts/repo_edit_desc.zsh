#!/bin/zsh
echo -n "Nombre del repo (owner/repo, q para cancelar): "
read repodesc
[[ "$repodesc" == "q" || -z "$repodesc" ]] && echo "Acción cancelada." && exit 1
echo -n "Nueva descripción: "
read newdesc
gh repo edit "$repodesc" --description "$newdesc" && echo "Descripción actualizada." 