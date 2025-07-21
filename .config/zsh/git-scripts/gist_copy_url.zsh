#!/bin/zsh
gist_id=$(gh gist list | fzf --prompt="Selecciona Gist para copiar URL: " | awk '{print $1}')
[[ -z "$gist_id" ]] && echo "No se seleccionó ningún Gist." && exit 1
url=$(gh gist view "$gist_id" --json url -q .url)
echo -n "$url" | xclip -selection clipboard && echo "URL copiada al portapapeles." 