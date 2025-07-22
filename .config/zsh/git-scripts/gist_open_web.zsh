#!/usr/bin/env zsh

if ! command -v gh &>/dev/null; then
  echo "Error: gh (GitHub CLI) no está instalado." >&2
  exit 1
fi
if ! command -v fzf &>/dev/null; then
  echo "Error: fzf no está instalado." >&2
  exit 1
fi

gist_id=$(gh gist list --limit 100 | fzf --prompt="Selecciona un Gist para abrir en el navegador: " | awk '{print $1}')
if [[ -z "$gist_id" ]]; then
  echo "No se seleccionó ningún Gist."
  exit 1
fi

gh gist view "$gist_id" --web 