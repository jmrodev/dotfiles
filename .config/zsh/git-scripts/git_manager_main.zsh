#!/bin/zsh

while true; do
  menu=$(printf "🖥️  Menú Git local (dotfiles/repos locales)\n🐙 Menú GitHub avanzado (Gists, Issues, PRs, Repos remotos)\n❌ Salir" | fzf --prompt="¿Qué menú quieres usar? (q para salir) " --height=30% --border)
  case "$menu" in
    "🖥️  Menú Git local (dotfiles/repos locales)")
      ~/.config/zsh/git-scripts/git_manager_local.zsh
      ;;
    "🐙 Menú GitHub avanzado (Gists, Issues, PRs, Repos remotos)")
      ~/.config/zsh/git-scripts/git_manager.zsh
      ;;
    "❌ Salir" | "")
      break
      ;;
  esac
  clear
done 