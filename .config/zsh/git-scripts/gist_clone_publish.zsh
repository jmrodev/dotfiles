#!/usr/bin/env zsh

# Verifica dependencias
for cmd in gh fzf git; do
  if ! command -v $cmd &>/dev/null; then
    echo "Error: $cmd no está instalado." >&2
    exit 1
  fi
done

# Selecciona el Gist a clonar
gist_id=$(gh gist list --limit 100 | fzf --prompt="Selecciona un Gist para clonar/publicar: " | awk '{print $1}')
if [[ -z "$gist_id" ]]; then
  echo "No se seleccionó ningún Gist."
  exit 1
fi

# Obtiene la descripción del Gist
description=$(gh gist view "$gist_id" | head -n 1)

# Clona el Gist localmente
tmpdir=$(mktemp -d)
gh gist clone "$gist_id" "$tmpdir"
cd "$tmpdir" || exit 1

# Pregunta visibilidad
echo "¿Qué visibilidad quieres para el nuevo Gist?"
select vis in "public" "secret"; do
  case $vis in
    public|secret) break;;
    *) echo "Opción inválida";;
  esac
done

# Limpia la variable de visibilidad
gist_vis=$(echo "$vis" | tr -d '[:space:]')
if [[ "$gist_vis" == "secret" ]]; then
  gh gist create * --desc "$description"
else
  gh gist create * --desc "$description" --public
fi

echo "Gist clonado y publicado como $vis."
echo "Directorio temporal: $tmpdir"
echo "Puedes eliminarlo manualmente si lo deseas."

# Pregunta si quiere borrar el original
read "del?¿Quieres borrar el Gist original? (s/N): "
if [[ "$del" =~ ^[sS]$ ]]; then
  gh gist delete "$gist_id"
  echo "Gist original eliminado."
fi 