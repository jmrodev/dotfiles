#!/bin/zsh

# ~/.config/zsh/functions/git/git_manager.zsh

git_manager() {
  # Menú para elegir el tipo de repo
  local mode
  mode=$(printf "🛠️  Dotfiles\n📁 Git estándar (buscar en $HOME)" | fzf --prompt="¿Qué repo quieres gestionar? " --height=20% --border)
  [[ -z "$mode" ]] && return

  local repo_path
  if [[ "$mode" == "🛠️  Dotfiles" ]]; then
    repo_path="$HOME"
  else
    # Buscar todos los repos git en $HOME y subcarpetas, excluyendo rutas de aplicaciones y cachés
    repo_path=$(find $HOME -type d -name ".git" \
      -not -path "$HOME/.local/share/nvim/*" \
      -not -path "$HOME/.cache/yay/*" \
      -not -path "$HOME/.local/share/Trash/*" \
      -not -path "$HOME/.local/share/flatpak/*" \
      -not -path "$HOME/.local/share/Steam/*" \
      -not -path "$HOME/.local/share/gnome-shell/*" \
      -not -path "$HOME/.local/share/JetBrains/*" \
      -not -path "$HOME/.local/share/Code/*" \
      -not -path "$HOME/.local/share/gvfs-metadata/*" \
      -not -path "$HOME/.local/share/RecentDocuments/*" \
      -not -path "$HOME/.local/share/Trash/*" \
      -not -path "$HOME/.local/share/containers/*" \
      -not -path "$HOME/.local/share/virtualenvs/*" \
      -not -path "$HOME/.local/share/paru/*" \
      -not -path "$HOME/.local/share/pnpm/*" \
      -not -path "$HOME/.cache/*" \
      2>/dev/null | sed 's|/\.git$||' | fzf --prompt="Selecciona un repo git: ")
    [[ -z "$repo_path" ]] && return
  fi

  # Función para seleccionar archivos a agregar (para git estándar)
  _git_add_select() {
    local path="$1"
    local files
    files=$(git -C "$path" status -s | awk '{print $2}' | fzf -m --prompt="Selecciona archivos para agregar (q para cancelar): ")
    if [[ -z "$files" ]]; then
      echo "No se seleccionó ningún archivo."
      read -k1 -s -p $'\nPresiona cualquier tecla para continuar...'
      return
    fi
    git -C "$path" add $files
    echo "Archivos agregados:"
    echo "$files"
    read -k1 -s -p $'\nPresiona cualquier tecla para continuar...'
  }

  # Función para dotfiles_add_select con feedback
  _dotfiles_add_select_feedback() {
    local files
    files=$(dotfiles status -s | awk '{print $2}' | fzf -m --prompt="Selecciona archivos para agregar (q para cancelar): ")
    if [[ -z "$files" ]]; then
      echo "No se seleccionó ningún archivo."
      read -k1 -s -p $'\nPresiona cualquier tecla para continuar...'
      return
    fi
    dotfiles add $files
    echo "Archivos agregados:"
    echo "$files"
    read -k1 -s -p $'\nPresiona cualquier tecla para continuar...'
  }

  while true; do
    local action
    action=$(printf "📄 Estado\n➕ Agregar archivos\n📝 Commit\n⬆️  Push\n🔍 Log\n🔀 Checkout\n🔄 Pull\n🔃 Fetch\n🗑️ Stash\n🔎 Diff\n❌ Salir" | fzf --prompt="¿Qué quieres hacer? (q para volver) " --height=40% --border)
    case "$action" in
      "📄 Estado")
        if [[ "$mode" == "🛠️  Dotfiles" ]]; then
          dotfiles status | less
        else
          git -C "$repo_path" status | less
        fi
        ;;
      "➕ Agregar archivos")
        if [[ "$mode" == "🛠️  Dotfiles" ]]; then
          _dotfiles_add_select_feedback
        else
          _git_add_select "$repo_path"
        fi
        ;;
      "📝 Commit")
        echo -n "Mensaje de commit (q para cancelar): "
        read msg
        if [[ "$msg" == "q" ]]; then
          echo "Commit cancelado."
          read -k1 -s -p $'\nPresiona cualquier tecla para continuar...'
          continue
        fi
        if [[ "$mode" == "🛠️  Dotfiles" ]]; then
          if dotfiles diff --cached --quiet; then
            echo "No hay cambios para commitear."
          else
            dotfiles commit -m "$msg" && echo "Commit realizado: $msg"
          fi
        else
          if git -C "$repo_path" diff --cached --quiet; then
            echo "No hay cambios para commitear."
          else
            git -C "$repo_path" commit -m "$msg" && echo "Commit realizado: $msg"
          fi
        fi
        read -k1 -s -p $'\nPresiona cualquier tecla para continuar...'
        ;;
      "⬆️  Push")
        if [[ "$mode" == "🛠️  Dotfiles" ]]; then
          dotfiles push && echo "Push realizado."
        else
          git -C "$repo_path" push && echo "Push realizado."
        fi
        read -k1 -s -p $'\nPresiona cualquier tecla para continuar...'
        ;;
      "🔍 Log")
        if [[ "$mode" == "🛠️  Dotfiles" ]]; then
          dotfiles log --oneline --decorate --graph --all | less
        else
          git -C "$repo_path" log --oneline --decorate --graph --all | less
        fi
        ;;
      "🔀 Checkout")
        if [[ "$mode" == "🛠️  Dotfiles" ]]; then
          local branch
          branch=$(dotfiles branch | fzf --prompt="Selecciona rama (q para cancelar): ")
          if [[ -z "$branch" ]]; then
            echo "No se seleccionó ninguna rama."
            read -k1 -s -p $'\nPresiona cualquier tecla para continuar...'
            continue
          fi
          dotfiles checkout "$(echo $branch | awk '{print $1}')"
          echo "Cambiado a rama: $(echo $branch | awk '{print $1}')"
        else
          local branch
          branch=$(git -C "$repo_path" branch | fzf --prompt="Selecciona rama (q para cancelar): ")
          if [[ -z "$branch" ]]; then
            echo "No se seleccionó ninguna rama."
            read -k1 -s -p $'\nPresiona cualquier tecla para continuar...'
            continue
          fi
          git -C "$repo_path" checkout "$(echo $branch | awk '{print $1}')"
          echo "Cambiado a rama: $(echo $branch | awk '{print $1}')"
        fi
        read -k1 -s -p $'\nPresiona cualquier tecla para continuar...'
        ;;
      "🔄 Pull")
        if [[ "$mode" == "🛠️  Dotfiles" ]]; then
          dotfiles pull && echo "Pull realizado."
        else
          git -C "$repo_path" pull && echo "Pull realizado."
        fi
        read -k1 -s -p $'\nPresiona cualquier tecla para continuar...'
        ;;
      "🔃 Fetch")
        if [[ "$mode" == "🛠️  Dotfiles" ]]; then
          dotfiles fetch --all --prune && echo "Fetch realizado."
        else
          git -C "$repo_path" fetch --all --prune && echo "Fetch realizado."
        fi
        read -k1 -s -p $'\nPresiona cualquier tecla para continuar...'
        ;;
      "🗑️ Stash")
        if [[ "$mode" == "🛠️  Dotfiles" ]]; then
          if dotfiles diff --quiet; then
            echo "No hay cambios para guardar en stash."
          else
            dotfiles stash && echo "Stash realizado."
          fi
        else
          if git -C "$repo_path" diff --quiet; then
            echo "No hay cambios para guardar en stash."
          else
            git -C "$repo_path" stash && echo "Stash realizado."
          fi
        fi
        read -k1 -s -p $'\nPresiona cualquier tecla para continuar...'
        ;;
      "🔎 Diff")
        if [[ "$mode" == "🛠️  Dotfiles" ]]; then
          dotfiles diff | less
        else
          git -C "$repo_path" diff | less
        fi
        ;;
      "❌ Salir" | "")
        break
        ;;
    esac
    clear
  done
}

git_manager 