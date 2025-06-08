# ~/.config/zsh/functions/git/git_feature_start.zsh
# git_feature_start <nombre-feature>
# Asume que la rama de desarrollo principal se llama 'develop'
git_feature_start() {
  local feature_name="$1"
  local develop_branch="develop" # Puedes cambiar esto si tu rama es 'main' o 'master'

  if [[ -z "$feature_name" ]]; then
    echo "Error: Debes proporcionar un nombre para la feature."
    return 1
  fi

  # Verificar si la rama develop existe
  if ! git show-ref --verify --quiet "refs/heads/$develop_branch" && ! git show-ref --verify --quiet "refs/remotes/origin/$develop_branch"; then
    echo "Advertencia: La rama '$develop_branch' no parece existir localmente ni en origin. Intentando continuar..."
    # Podrías querer hacer 'git checkout main' o la rama principal por defecto aquí como fallback.
  fi

  git checkout "$develop_branch" && \
  git pull origin "$develop_branch" && \
  git checkout -b "feature/$feature_name" "$develop_branch"
}
