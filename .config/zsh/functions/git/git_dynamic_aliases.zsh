# ~/.config/zsh/functions/git/git_dynamic_aliases.zsh
# Funciones que necesitan evaluar dinámicamente la rama actual
# Estas reemplazan aliases que usan $(git_current_branch) para evitar errores de evaluación

# Push y establecer upstream a la rama actual
gpusho() {
  local current_branch
  if command -v git_current_branch &> /dev/null; then
    current_branch=$(git_current_branch)
  else
    current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  fi
  
  if [[ -n "$current_branch" ]]; then
    echo "Haciendo push de '$current_branch' y estableciendo upstream..."
    git push -u origin "$current_branch"
  else
    echo "Error: No estás en una rama de Git válida."
    return 1
  fi
}

# Versión para dotfiles
dpusho() {
  local current_branch
  if command -v dotfiles_current_branch &> /dev/null; then
    current_branch=$(dotfiles_current_branch)
  else
    current_branch=$(dotfiles rev-parse --abbrev-ref HEAD 2>/dev/null)
  fi
  
  if [[ -n "$current_branch" ]]; then
    echo "Haciendo push de dotfiles '$current_branch' y estableciendo upstream..."
    dotfiles push -u origin "$current_branch"
  else
    echo "Error: No estás en una rama de dotfiles válida."
    return 1
  fi
}

# Función helper para mostrar información de la rama actual
show_current_branch() {
  local current_branch
  if command -v git_current_branch &> /dev/null; then
    current_branch=$(git_current_branch)
  else
    current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  fi
  
  if [[ -n "$current_branch" ]]; then
    echo "Rama actual: $current_branch"
  else
    echo "No estás en un repositorio Git o no hay rama activa."
    return 1
  fi
}

# Función helper para mostrar información de la rama actual de dotfiles
show_current_dotfiles_branch() {
  local current_branch
  if command -v dotfiles_current_branch &> /dev/null; then
    current_branch=$(dotfiles_current_branch)
  else
    current_branch=$(dotfiles rev-parse --abbrev-ref HEAD 2>/dev/null)
  fi
  
  if [[ -n "$current_branch" ]]; then
    echo "Rama actual de dotfiles: $current_branch"
  else
    echo "No estás en un repositorio de dotfiles válido o no hay rama activa."
    return 1
  fi
}