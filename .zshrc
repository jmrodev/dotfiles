# === CARGA DE FASTFETCH ===
fastfetch

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# === CONFIGURACION BASE ZSH ===
HISTFILE=~/.histfile
HISTSIZE=50000
SAVEHIST=50000
# Evitar comandos duplicados en el historial
setopt HIST_IGNORE_DUPS          # No guardar si es igual al anterior
setopt HIST_IGNORE_ALL_DUPS      # Borrar duplicados previos
setopt HIST_SAVE_NO_DUPS         # No guardar duplicados en el archivo
setopt HIST_REDUCE_BLANKS        # Eliminar espacios sobrantes
setopt INC_APPEND_HISTORY        # Actualizar historial inmediatamente
setopt SHARE_HISTORY             # Compartir historial entre sesiones
setopt EXTENDED_HISTORY          # Guardar timestamp del comando (cuándo se ejecutó)
setopt HIST_FIND_NO_DUPS         # No mostrar duplicados al buscar hacia atrás
setopt AUTO_PUSHD                # cd guarda en el stack (puedes usar cd -[TAB])
setopt PUSHD_IGNORE_DUPS         # No duplicar directorios en el stack
setopt autocd beep extendedglob nomatch notify
bindkey -e

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git sudo z zsh-autosuggestions fast-syntax-highlighting zsh-autocomplete archlinux extract web-search copyfile dirhistory
)

source $ZSH/oh-my-zsh.sh

# === ALIAS Y ATAJOS ===
[[ -f ~/.zsh_aliases ]] && source ~/.zsh_aliases

# === FUNCIONES ===
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# === CONFIGURACION DE AUTOCOMPLETADO (IDE STYLE) ===
# 1. Ajustes del plugin zsh-autocomplete
zstyle ':autocomplete:*' delay 0.8
zstyle ':autocomplete:*' list-lines 50
zstyle ':autocomplete:tab:*' insert-unambiguous yes

# 2. Habilitar Grupos y Títulos (Obligatorio para separar Alias de Comandos)
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%B%F{yellow}-- %d --%f%b'

# 3. ORDEN DE PRIORIDAD (Aliases primero, luego funciones, luego comandos, luego rutas)
zstyle ':completion:*' tag-order 'aliases' 'functions' 'commands' 'builtins' 'local-directories' 'directories' 'files'
zstyle ':completion:*' group-order aliases functions commands builtins local-directories directories files

# 4. Estética General
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' verbose yes

# === BUSQUEDA CON FLECHAS ===
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

# === HERRAMIENTAS ===
eval "$(zoxide init zsh)"
source <(fzf --zsh)

[[ -f ~/.config/pnpm/env ]] && source ~/.config/pnpm/env
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# pnpm
export PNPM_HOME="/home/jmro/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end
alias npm="pnpm"
alias npx="pnpm dlx"

# === SECRETOS Y TOKENS ===
[[ -f ~/.zsh_secrets ]] && source ~/.zsh_secrets

# === INTEGRACIÓN CON DOTFILES MODULARES ===
for func in ~/.config/zsh/functions/utils/*; do
    [[ -f "$func" ]] && source "$func"
done
[[ -f ~/.config/zsh/aliases.zsh ]] && source ~/.config/zsh/aliases.zsh

# Path
export PATH="/home/jmro/.local/bin:$PATH"
