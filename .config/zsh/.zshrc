# ~/.zshrc
# Definición de la función dotfiles para gestionar el repositorio bare
dotfiles() {
    git --git-dir=$HOME/.dotfiles --work-tree=$HOME "$@"
}

# Configuración del tema y plugins de Oh My Zsh
# ---------------------------------------------

# Tema (Powerlevel10k clonado en custom/themes)
ZSH_THEME="powerlevel10k/powerlevel10k"

# Lista de plugins a cargar (clonados en custom/plugins)
# El orden importa, especialmente para zsh-syntax-highlighting, que debe ir al final.
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

# Carga de Oh My Zsh
if [ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
    source "$HOME/.oh-my-zsh/oh-my-zsh.sh"
fi

# Carga de archivos de configuración modulares
# -------------------------------------------

# Directorio base para la configuración de Zsh
ZDOTDIR=${ZDOTDIR:-$HOME/.config/zsh}

# Lista de archivos a cargar en orden
config_files=(
    options.zsh
    aliases.zsh
    keybindings.zsh
    plugins.zsh # Ahora solo contiene fzf, thefuck y funciones
    # git-scripts/git_manager_main.zsh
)

# Bucle para cargar los archivos de configuración
for config_file in "${config_files[@]}"; do
    if [ -f "$ZDOTDIR/$config_file" ]; then
        source "$ZDOTDIR/$config_file"
    fi
done

# Limpieza de variables para no dejar rastros
unset config_files config_file

# Funciones no gestionadas por el sistema de plugins
# (Asegúrate de que no haya conflictos con los plugins cargados)

# Des-registrar funciones para evitar errores en la recarga
# Se comprueba si la función existe antes de intentar eliminarla.
functions_to_undef=(
  gup gupm gunwip gwip gcbp gdelb git_current_branch dotfiles_current_branch
  git_feature_start git_feature_finish dotfiles_add_select
)
for func in ${functions_to_undef[@]}; do
  if typeset -f "$func" > /dev/null; then
    unfunction "$func"
  fi
done
unset functions_to_undef func

# Cargar scripts de funciones dinámicas
if [ -f "$ZDOTDIR/functions/git/git_dynamic_aliases" ]; then
    source "$ZDOTDIR/functions/git/git_dynamic_aliases"
fi


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
# --- Detección del Sistema Operativo para cargar funciones específicas ---
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_ID=$ID
fi

fpath=(~/.config/zsh/functions/utils \
~/.config/zsh/functions \
~/.config/zsh/functions/git \
~/.config/zsh/functions/fileops \
$fpath)

# Cargar funciones de gestión de servicios según el SO
if [ "$OS_ID" = "arch" ]; then
    fpath+=(~/.config/zsh/functions/systemd)
elif [ "$OS_ID" = "void" ]; then
    fpath+=(~/.config/zsh/functions/runit)
fi

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