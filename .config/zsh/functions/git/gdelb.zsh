# ~/.config/zsh/functions/git/gdelb.zsh
# gdelb <nombre-rama>
# Borra una rama localmente y en origin.
gdelb() {
  local branch_name="$1"
  local current_branch

  # Necesita que git_current_branch esté disponible o definirla aquí
  if command -v git_current_branch &> /dev/null; then
    current_branch=$(git_current_branch)
  else
    current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  fi

  if [[ -z "$branch_name" ]]; then
    echo "Error: Debes proporcionar el nombre de la rama a borrar."
    return 1
  fi

  if [[ "$branch_name" == "$current_branch" ]]; then
    echo "Error: No puedes borrar la rama en la que estás actualmente ($current_branch)."
    echo "Cambia a otra rama primero."
    return 1
  fi

  # Preguntar confirmación (Zsh specific 'read -q')
  # Para Bash, se usaría 'read -r -p "..." REPLY'
  if [[ -n "$ZSH_VERSION" ]]; then
    read -q "REPLY?¿Estás seguro de que quieres borrar la rama '$branch_name' localmente y en 'origin'? (y/N): "
  else # Bash fallback
    read -r -p "¿Estás seguro de que quieres borrar la rama '$branch_name' localmente y en 'origin'? (y/N): " REPLY
  fi
  echo # Nueva línea después de la entrada

  if ! [[ "$REPLY" =~ ^[Yy]$ ]]; then
    echo "Cancelado."
    return 0
  fi

  git branch -D "$branch_name" && \
  git push origin --delete "$branch_name"
}
