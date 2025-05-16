# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
	if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
	  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
	fi

typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# ⚠️ Recomendación: mueve tu API KEY a un archivo seguro y no la publiques
# export GEMINI_API_KEY='TU_API_KEY_AQUI'
# Cargar secretos si el archivo existe
if [ -f ~/.zsh_secrets ]; then
  . ~/.zsh_secrets
fi
#			USE_POWERLINE="true" # Define una bandera para que manjaro-zsh-prompt use la configuración Powerline

#			unsetopt CORRECT_ALL
# o para una corrección menos agresiva
# unsetopt CORRECT_ALL

# Source manjaro-zsh-config (contiene opciones base, keybindings, theming, carga plugins del sistema)
#			if [[ -e /usr/share/zsh/manjaro-zsh-config ]]; then
#  				source /usr/share/zsh/manjaro-zsh-config
#			fi

# Use manjaro zsh prompt (contiene la lógica para cargar Powerlevel10k o Maia)
#			if [[ -e /usr/share/zsh/manjaro-zsh-prompt ]]; then
#			  source /usr/share/zsh/manjaro-zsh-prompt
#			fi

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export EDITOR="nvim"
export VISUAL="$EDITOR"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"
# Set list of themes to pick from when loading at random
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f&"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
plugins=(
    git
    zsh-syntax-highlighting
    zsh-autosuggestions
    fzf
)

source $ZSH/oh-my-zsh.sh

# User configuration
export PATH="$HOME/bin:$PATH"
export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=es_AR.UTF-8

ranger_cd() {
    local tempfile="$(mktemp)"
    command ranger --choosedir="$tempfile" "$@"
    if [ -f "$tempfile" ]; then
        local dir="$(cat "$tempfile")"
        rm -f "$tempfile"
        if [ -d "$dir" ]; then
            if [ "$dir" != "$(pwd)" ]; then
                cd -- "$dir"
            fi
        fi
    fi
}

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
alias zshconfig="nvim ~/.zshrc"
alias ohmyzsh="nvim ~/.oh-my-zsh"
alias ls='exa --icons --color=always'
alias top='glances'
alias htop='glances'
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
bindkey -s '^[[1;5C' 'ranger_cd\n'
eval $(thefuck --alias)

disk_usage() {
    df -h | grep '^/dev/' | awk '{printf "%s: %s (%s used)\n", $1, $4, $5}'
}



# Agregar estas líneas a tu archivo ~/.zshrc para mostrar
# un mensaje ASCII art aleatorio cada vez que abras una terminal

# Definir la ruta al script
MENSAJE_SCRIPT="$HOME/scripts/message_on_start_terminal"

# Verificar si el script existe y es ejecutable
if [[ -x "$MENSAJE_SCRIPT" ]]; then
    # Ejecutar el script (modo silencioso)
    "$MENSAJE_SCRIPT" --quiet
else
    echo "Script de mensajes ASCII no encontrado en $MENSAJE_SCRIPT"
    echo "Asegúrate de guardarlo en esa ubicación y hacerlo ejecutable con:"
    echo "mkdir -p ~/scripts && chmod +x $MENSAJE_SCRIPT"
fi



echo "---------------------------------------------------"
echo "  Bienvenido, $USER@$(hostname)  "
echo "---------------------------------------------------"
echo "  SO: $(uname -s) | Kernel: $(uname -r)"
echo "  Tiempo activo: $(uptime -p)"
disk_usage
echo "---------------------------------------------------"


# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
