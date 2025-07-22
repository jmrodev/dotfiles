#!/usr/bin/env zsh

# Verifica dependencias
if ! command -v gh &>/dev/null; then
  echo "Error: gh (GitHub CLI) no está instalado." >&2
  exit 1
fi
if ! command -v fzf &>/dev/null; then
  echo "Error: fzf no está instalado." >&2
  exit 1
fi

# Selecciona el Gist
gist_id=$(gh gist list --limit 100 | fzf --prompt="Selecciona un Gist para leer: " | awk '{print $1}')
if [[ -z "$gist_id" ]]; then
  echo "No se seleccionó ningún Gist."
  exit 1
fi

# Obtiene la lista de archivos del Gist
file_list=(${(@f)$(gh gist view "$gist_id" --files)})
if (( ${#file_list[@]} == 0 )); then
  echo "El Gist no tiene archivos."
  exit 1
fi

# Si hay más de un archivo, permite elegir cuál leer
if (( ${#file_list[@]} > 1 )); then
  file_name=$(printf "%s\n" "${file_list[@]}" | fzf --prompt="Selecciona el archivo a leer: ")
else
  file_name="${file_list[1]}"
fi

if [[ -z "$file_name" ]]; then
  echo "No se seleccionó ningún archivo."
  exit 1
fi

# Muestra el contenido del archivo seleccionado
gh gist view "$gist_id" --filename "$file_name" --raw | less 