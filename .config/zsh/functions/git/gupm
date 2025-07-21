# ~/.config/zsh/functions/git/gupm.zsh
# gupm
# Actualiza la rama actual: fetch de origin y merge con origin/rama_actual
gupm() {
  local current_branch
  # Necesita que git_current_branch esté disponible o definirla aquí
  if command -v git_current_branch &> /dev/null; then
    current_branch=$(git_current_branch)
  else
    current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  fi

  if [[ -n "$current_branch" ]]; then
    echo "Actualizando rama '$current_branch' desde origin con merge..."
    command git fetch origin "$current_branch" && command git merge "origin/$current_branch"
  else
    echo "No estás en una rama de Git."
    return 1
  fi
}
