# ~/.config/zsh/functions/git/gcbp.zsh
# gcbp <nombre-rama> [rama-base]
# Crea una nueva rama, cambia a ella y la pushea a origin.
# Si no se especifica rama-base, usa la rama actual.
gcbp() {
  local new_branch_name="$1"
  local base_branch
  
  # Si no se proporciona rama base, intenta usar la rama actual de git
  # Necesita que git_current_branch esté disponible o definirla aquí
  if command -v git_current_branch &> /dev/null; then
    base_branch="${2:-$(git_current_branch)}"
  else
    # Fallback si git_current_branch no está (aunque debería estar)
    base_branch="${2:-$(git rev-parse --abbrev-ref HEAD 2>/dev/null)}"
  fi


  if [[ -z "$new_branch_name" ]]; then
    echo "Error: Debes proporcionar un nombre para la nueva rama."
    return 1
  fi

  if [[ -z "$base_branch" ]]; then
    echo "Error: No se pudo determinar la rama base. Asegúrate de estar en un repositorio Git."
    return 1
  fi

  git checkout -b "$new_branch_name" "$base_branch" && \
  git push -u origin "$new_branch_name"
}
