# ~/.config/zsh/.zshrc
# Entry point modular gestionado por dotfiles (SSoT)

# --- FASTFETCH ---
fastfetch

# Enable Powerlevel10k instant prompt.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Definición de la función dotfiles
unalias dotfiles 2>/dev/null
dotfiles() {
    /usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME "$@"
}

# --- OH MY ZSH ---
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins de Oh My Zsh (Lista expandida sumando local + repo)
plugins=(
    git 
    sudo 
    z 
    zsh-autosuggestions 
    fast-syntax-highlighting 
    zsh-autocomplete 
    archlinux 
    extract 
    web-search 
    copyfile 
    dirhistory
)

[[ -f "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

# --- CONFIGURACIÓN MODULAR ---
ZDOTDIR=${ZDOTDIR:-$HOME/.config/zsh}

# Limpieza de funciones para evitar errores en recarga (Copiado íntegro del repo)
functions_to_undef=(
  gupm gunwip gwip gcbp gdelb git_current_branch dotfiles_current_branch
  git_feature_start git_feature_finish dotfiles_add_select
)
for func in ${functions_to_undef[@]}; do
  if typeset -f "$func" > /dev/null; then
    unfunction "$func"
  fi
done
unset functions_to_undef func

# Carga de archivos en orden
config_files=(
    options.zsh
    keybindings.zsh
    plugins.zsh
)

for config_file in "${config_files[@]}"; do
    [[ -f "$ZDOTDIR/$config_file" ]] && source "$ZDOTDIR/$config_file"
done

# --- INTEGRACIÓN CON MANJARO (Sumado del repo original) ---
[[ -f /usr/share/zsh/manjaro-zsh-config ]] && source /usr/share/zsh/manjaro-zsh-config
[[ -f /usr/share/zsh/manjaro-zsh-prompt ]] && source /usr/share/zsh/manjaro-zsh-prompt

# --- CARGA DE FUNCIONES (fpath y autoload) ---
# Detección de OS para fpath
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_ID=$ID
fi

fpath=(
  ~/.config/zsh/functions/utils
  ~/.config/zsh/functions/git
  ~/.config/zsh/functions/fileops
  $fpath
)

# Cargar sistema de servicios según el SO
if [[ "$OS_ID" == "arch" || "$OS_ID" == "manjaro" || "$OS_ID" == "debian" || "$OS_ID" == "ubuntu" ]]; then
    fpath+=(~/.config/zsh/functions/systemd)
elif [ "$OS_ID" = "void" ]; then
    fpath+=(~/.config/zsh/functions/runit)
fi

# Lista completa de funciones para autoload (Sumatoria total)
autoload -Uz calc ff top10 dirsize compress extract up urlencode title \
  swap lowercase start restart stop enable status disable \
  gup gupm gunwip gwip gcbp gdelb git_current_branch dotfiles_current_branch \
  git_feature_start git_feature_finish dotfiles_add_select git-publish gsync gforce gpub gstart gupdate

# --- SCRIPTS DINÁMICOS Y ALIAS ---
[[ -f "$ZDOTDIR/functions/git/git_dynamic_aliases" ]] && source "$ZDOTDIR/functions/git/git_dynamic_aliases"
[[ -f "$ZDOTDIR/aliases.zsh" ]] && source "$ZDOTDIR/aliases.zsh"

# --- HERRAMIENTAS ---
eval "$(zoxide init zsh)"
source <(fzf --zsh)

# PNPM
export PNPM_HOME="/home/jmro/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac

# PYENV
export PATH="$HOME/.pyenv/bin:$PATH"
if command -v pyenv &>/dev/null; then
    eval "$(pyenv init --path)"
    eval "$(pyenv virtualenv-init -)"
fi

# --- SECRETOS ---
[[ -f ~/.zsh_secrets ]] && source ~/.zsh_secrets

# --- PATH FINAL ---
export PATH="$HOME/.config/zsh/git-scripts:$HOME/.config/zsh/scripts:$HOME/.local/bin:$PATH"

# Cleanup
unset config_files config_file OS_ID

# Mensaje de ayuda inicial (Senior Tip)
echo -e "\033[0;33m💡 Tip: Escribe \033[1;32mdot-help\033[0;33m para ver tus comandos de gestión de dotfiles.\033[0m"
