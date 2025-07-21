# ~/.config/zsh/functions/git/git_feature_finish.zsh
# git_feature_finish <nombre-feature>
# Asume que la rama de desarrollo principal se llama 'develop'
git_feature_finish() {
  local feature_name="$1"
  local develop_branch="develop" # Puedes cambiar esto si tu rama es 'main' o 'master'

  if [[ -z "$feature_name" ]]; then
    echo "Error: Debes proporcionar un nombre para la feature."
    return 1
  fi

  # Verificar si la rama develop existe
  if ! command git show-ref --verify --quiet "refs/heads/$develop_branch" && ! command git show-ref --verify --quiet "refs/remotes/origin/$develop_branch"; then
    echo "Advertencia: La rama '$develop_branch' no parece existir localmente ni en origin. Intentando continuar..."
  fi

  # Verificar si la rama feature existe
  if ! command git show-ref --verify --quiet "refs/heads/feature/$feature_name"; then
    echo "Error: La rama 'feature/$feature_name' no existe localmente."
    return 1
  fi

  command git checkout "$develop_branch" && \
  command git pull origin "$develop_branch" && \
  command git merge --no-ff "feature/$feature_name" && \
  command git branch -d "feature/$feature_name" && \
  command git push origin "$develop_branch" # Opcional: push develop después de mergear
  # Opcional: Borrar rama remota si existe
  # command git push origin --delete "feature/$feature_name"
}
