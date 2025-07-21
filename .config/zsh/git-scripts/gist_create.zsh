#!/bin/zsh
echo -n "Ruta del archivo a subir como Gist (q para cancelar): "
read gistfile
[[ "$gistfile" == "q" || ! -f "$gistfile" ]] && echo "Acción cancelada o archivo no existe." && exit 1
echo -n "Descripción: "
read gistdesc
echo "¿Privado? (s/n): "
read priv
[[ "$priv" == "s" ]] && private="--private" || private=""
gh gist create $private -d "$gistdesc" "$gistfile" && echo "Gist creado."
