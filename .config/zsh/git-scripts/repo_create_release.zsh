#!/bin/zsh
echo -n "Nombre del repo (owner/repo, q para cancelar): "
read reporel
[[ "$reporel" == "q" || -z "$reporel" ]] && echo "Acción cancelada." && exit 1
echo -n "Tag: "
read tag
[[ "$tag" == "q" || -z "$tag" ]] && echo "Acción cancelada." && exit 1
echo -n "Título del release: "
read title
echo -n "Descripción: "
read desc
gh release create "$tag" --repo "$reporel" --title "$title" --notes "$desc" && echo "Release creado." 