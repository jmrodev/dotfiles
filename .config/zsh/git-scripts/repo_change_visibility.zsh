#!/bin/zsh
echo -n "Nombre del repo (owner/repo, q para cancelar): "
read repovis
[[ "$repovis" == "q" || -z "$repovis" ]] && echo "Acción cancelada." && exit 1
echo "¿Privado? (s/n): "
read priv
if [[ "$priv" == "s" ]]; then
  gh repo edit "$repovis" --visibility private && echo "Repo ahora es privado."
else
  gh repo edit "$repovis" --visibility public && echo "Repo ahora es público."
fi 