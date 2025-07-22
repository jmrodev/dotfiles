#!/usr/bin/env zsh

# Verifica dependencias
for cmd in gh fzf git; do
  if ! command -v $cmd &>/dev/null; then
    echo "Error: $cmd no está instalado." >&2
    exit 1
  fi
done

echo "Buscando todos tus Gists secretos..."

# Obtiene los IDs de todos los Gists secretos
secret_gists=(${(@f)$(gh gist list --secret --limit 1000 | awk '{print $1}')} )

# Debug: mostrar los IDs y la cantidad detectada
echo "IDs detectados: ${secret_gists[@]}"
echo "Cantidad: ${#secret_gists[@]}"

if (( ${#secret_gists[@]} == 0 )); then
  echo "No tienes Gists secretos."
  exit 0
fi

echo "Se encontraron ${#secret_gists[@]} Gists secretos."

for gist_id in "${secret_gists[@]}"; do
  echo "Procesando Gist $gist_id..."

  # Obtiene la descripción
  description=$(gh gist view "$gist_id" | head -n 1)

  # Clona el Gist
  tmpdir=$(mktemp -d)
  gh gist clone "$gist_id" "$tmpdir"
  cd "$tmpdir" || continue

  # Crea el nuevo Gist como público
  gh gist create * --desc "$description" --public

  cd - >/dev/null
  rm -rf "$tmpdir"

  # Elimina el Gist secreto original automáticamente
  gh gist delete "$gist_id" --yes
  echo "Gist $gist_id eliminado."
done

echo "¡Listo! Todos los Gists secretos han sido clonados como públicos." 