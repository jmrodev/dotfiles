#!/bin/zsh
echo -n "Nombre del repo (q para cancelar): "
read reponame
[[ "$reponame" == "q" || -z "$reponame" ]] && echo "Acción cancelada." && exit 1
echo -n "Descripción: "
read repodesc
echo "¿Privado? (s/n): "
read priv
[[ "$priv" == "s" ]] && private="--private" || private="--public"
gh repo create "$reponame" --description "$repodesc" $private && echo "Repo creado."
