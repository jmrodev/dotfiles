# ~/.zshrc
unalias dotfiles 2>/dev/null

dotfiles() {
  git --git-dir=$HOME/.dotfiles --work-tree=$HOME "$@"
}

# 1. Cargar secretos (como GEMINI_API_KEY) - Muy importante, debe ser el primero
if [[ -f ~/.zsh_secrets ]]; then
  source ~/.zsh_secrets
fi

if [[ -f /usr/share/zsh/manjaro-zsh-config ]]; then   
    source /usr/share/zsh/manjaro-zsh-config 
fi 

if [[ -f /usr/share/zsh/manjaro-zsh-prompt ]]; then   
    source /usr/share/zsh/manjaro-zsh-prompt 
fi

# 1. Funciones autoload (todas las subcarpetas)
fpath=(~/.config/zsh/functions/utils \
~/.config/zsh/functions \
~/.config/zsh/functions/git \
~/.config/zsh/functions/systemd \
~/.config/zsh/functions/fileops \
$fpath)

autoload -Uz calc ff top10 dirsize compress extract up urlencode title \
  swap lowercase start restart stop enable status disable \
  gup gupm gunwip gwip gcbp gdelb git_current_branch dotfiles_current_branch \
  git_feature_start git_feature_finish dotfiles_add_select

# 2. Scripts ejecutables (menús, utilidades grandes)
export PATH="$HOME/.config/zsh/git-scripts:$PATH"
export PATH="$HOME/.config/zsh/scripts:$PATH"

# 3. Alias útiles
source ~/.config/zsh/aliases.zsh

# 4. Menú principal de gestión git (local y GitHub)
# Ejecuta: git_manager_main.zsh para elegir menú
# Ejemplo: ~/.config/zsh/git-scripts/git_manager_main.zsh

# 5. Configuración de PNPM
export PNPM_HOME="/home/jmro/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# >>> pyenv initialization >>>
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv virtualenv-init -)"
# <<< pyenv initialization <<<