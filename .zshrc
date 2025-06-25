# ~/.zshrc

# ===============================================
#  CONFIGURACIÓN PRINCIPAL DE ZSH
#  Carga otros archivos de configuración
# ===============================================

# 1. Cargar secretos (como GEMINI_API_KEY) - Muy importante, debe ser el primero
if [[ -f ~/.zsh_secrets ]]; then
  source ~/.zsh_secrets
fi

# 2. Carga de tu archivo de configuración Zsh principal (desde .config/zsh)
#    Este archivo debería cargar aliases, keybindings, options, plugins, y theme.
if [[ -f ~/.config/zsh/.zshrc ]]; then
  source ~/.config/zsh/.zshrc
fi


alias ask="node /home/jmro/ask-gemini-nodejs/src/ask.js"


# ===============================================
#  FIN DE CONFIGURACIÓN DE ZSHRC
# ===============================================
# pnpm
export PNPM_HOME="/home/jmro/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
