#!/bin/zsh

while true; do
  action=$(printf "📋 Gists\n📦 Repositorios\n🐛 Issues\n🔀 Pull Requests\n❌ Salir" | fzf --prompt="¿Qué quieres gestionar? (q para volver) " --height=40% --border)
  case "$action" in
    "❌ Salir" | "") break;;
    "📋 Gists")
      while true; do
        gist_action=$(printf "➕ Crear Gist\n📄 Listar Gists\n👁️ Leer Gist\n🌐 Abrir Gist en navegador\n🔁 Clonar y publicar Gist\n🌍 Volver todos los Gists públicos\n✏️  Editar Gist\n🗑️  Borrar Gist\n📥 Descargar Gist\n🔗 Copiar URL de Gist\n🔙 Volver" | fzf --prompt="Acción Gist: (q para volver) " --height=40% --border)
        case "$gist_action" in
          "➕ Crear Gist") ~/.config/zsh/git-scripts/gist_create.zsh; read -k1 -s -p $'\nPresiona cualquier tecla para continuar...';;
          "📄 Listar Gists") ~/.config/zsh/git-scripts/gist_list.zsh; read -k1 -s -p $'\nPresiona cualquier tecla para continuar...';;
          "👁️ Leer Gist") ~/.config/zsh/git-scripts/gist_read.zsh; read -k1 -s -p $'\nPresiona cualquier tecla para continuar...';;
          "🌐 Abrir Gist en navegador") ~/.config/zsh/git-scripts/gist_open_web.zsh; read -k1 -s -p $'\nPresiona cualquier tecla para continuar...';;
          "🔁 Clonar y publicar Gist") ~/.config/zsh/git-scripts/gist_clone_publish.zsh; read -k1 -s -p $'\nPresiona cualquier tecla para continuar...';;
          "🌍 Volver todos los Gists públicos") ~/.config/zsh/git-scripts/gists_make_all_public.zsh; read -k1 -s -p $'\nPresiona cualquier tecla para continuar...';;
          "✏️  Editar Gist") ~/.config/zsh/git-scripts/gist_edit.zsh; read -k1 -s -p $'\nPresiona cualquier tecla para continuar...';;
          "🗑️  Borrar Gist") ~/.config/zsh/git-scripts/gist_delete.zsh; read -k1 -s -p $'\nPresiona cualquier tecla para continuar...';;
          "📥 Descargar Gist") ~/.config/zsh/git-scripts/gist_download.zsh; read -k1 -s -p $'\nPresiona cualquier tecla para continuar...';;
          "🔗 Copiar URL de Gist") ~/.config/zsh/git-scripts/gist_copy_url.zsh; read -k1 -s -p $'\nPresiona cualquier tecla para continuar...';;
          "🔙 Volver" | "") break;;
        esac
        clear
      done
      ;;
    "📦 Repositorios")
      while true; do
        repo_action=$(printf "➕ Crear repo\n🌐 Clonar repo\n🍴 Fork repo\n🗑️  Borrar repo\n👁️  Ver repo en navegador\n📝 Editar descripción\n🔄 Sincronizar fork\n👤 Cambiar visibilidad\n🏷️  Crear release/tag\n🔙 Volver" | fzf --prompt="Acción Repo: (q para volver) " --height=40% --border)
        case "$repo_action" in
          "➕ Crear repo") ~/.config/zsh/git-scripts/repo_create.zsh; read -k1 -s -p $'\nPresiona cualquier tecla para continuar...';;
          "🌐 Clonar repo") ~/.config/zsh/git-scripts/repo_clone.zsh; read -k1 -s -p $'\nPresiona cualquier tecla para continuar...';;
          "🍴 Fork repo") ~/.config/zsh/git-scripts/repo_fork.zsh; read -k1 -s -p $'\nPresiona cualquier tecla para continuar...';;
          "🗑️  Borrar repo") ~/.config/zsh/git-scripts/repo_delete.zsh; read -k1 -s -p $'\nPresiona cualquier tecla para continuar...';;
          "👁️  Ver repo en navegador") ~/.config/zsh/git-scripts/repo_view.zsh; read -k1 -s -p $'\nPresiona cualquier tecla para continuar...';;
          "📝 Editar descripción") ~/.config/zsh/git-scripts/repo_edit_desc.zsh; read -k1 -s -p $'\nPresiona cualquier tecla para continuar...';;
          "🔄 Sincronizar fork") ~/.config/zsh/git-scripts/repo_sync_fork.zsh; read -k1 -s -p $'\nPresiona cualquier tecla para continuar...';;
          "👤 Cambiar visibilidad") ~/.config/zsh/git-scripts/repo_change_visibility.zsh; read -k1 -s -p $'\nPresiona cualquier tecla para continuar...';;
          "🏷️  Crear release/tag") ~/.config/zsh/git-scripts/repo_create_release.zsh; read -k1 -s -p $'\nPresiona cualquier tecla para continuar...';;
          "🔙 Volver" | "") break;;
        esac
        clear
      done
      ;;
    "🐛 Issues")
      while true; do
        issue_action=$(printf "📄 Listar Issues\n➕ Crear Issue\n✏️  Editar Issue\n✅ Cerrar Issue\n🔍 Buscar Issues\n🔙 Volver" | fzf --prompt="Acción Issue: (q para volver) " --height=40% --border)
        case "$issue_action" in
          "📄 Listar Issues") ~/.config/zsh/git-scripts/issue_list.zsh; read -k1 -s -p $'\nPresiona cualquier tecla para continuar...';;
          "➕ Crear Issue") ~/.config/zsh/git-scripts/issue_create.zsh; read -k1 -s -p $'\nPresiona cualquier tecla para continuar...';;
          "✏️  Editar Issue") ~/.config/zsh/git-scripts/issue_edit.zsh; read -k1 -s -p $'\nPresiona cualquier tecla para continuar...';;
          "✅ Cerrar Issue") ~/.config/zsh/git-scripts/issue_close.zsh; read -k1 -s -p $'\nPresiona cualquier tecla para continuar...';;
          "🔍 Buscar Issues") ~/.config/zsh/git-scripts/issue_search.zsh; read -k1 -s -p $'\nPresiona cualquier tecla para continuar...';;
          "🔙 Volver" | "") break;;
        esac
        clear
      done
      ;;
    "🔀 Pull Requests")
      while true; do
        pr_action=$(printf "📄 Listar PRs\n➕ Crear PR\n✏️  Editar PR\n✅ Mergear PR\n❌ Cerrar PR\n🔍 Buscar PRs\n🔙 Volver" | fzf --prompt="Acción PR: (q para volver) " --height=40% --border)
        case "$pr_action" in
          "📄 Listar PRs") ~/.config/zsh/git-scripts/pr_list.zsh; read -k1 -s -p $'\nPresiona cualquier tecla para continuar...';;
          "➕ Crear PR") ~/.config/zsh/git-scripts/pr_create.zsh; read -k1 -s -p $'\nPresiona cualquier tecla para continuar...';;
          "✏️  Editar PR") ~/.config/zsh/git-scripts/pr_edit.zsh; read -k1 -s -p $'\nPresiona cualquier tecla para continuar...';;
          "✅ Mergear PR") ~/.config/zsh/git-scripts/pr_merge.zsh; read -k1 -s -p $'\nPresiona cualquier tecla para continuar...';;
          "❌ Cerrar PR") ~/.config/zsh/git-scripts/pr_close.zsh; read -k1 -s -p $'\nPresiona cualquier tecla para continuar...';;
          "🔍 Buscar PRs") ~/.config/zsh/git-scripts/pr_search.zsh; read -k1 -s -p $'\nPresiona cualquier tecla para continuar...';;
          "🔙 Volver" | "") break;;
        esac
        clear
      done
      ;;
  esac
  clear
done
