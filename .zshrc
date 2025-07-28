# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="powerlevel10k/powerlevel10k"

# Which plugins would you like to load?
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# Carga Oh My Zsh. Esto también establecerá ZSH_CUSTOM y cargará los plugins listados.
source $ZSH/oh-my-zsh.sh

# --- AQUI ES DONDE CARGAS TU ARCHIVO DE CONFIGURACIÓN SECUNDARIO ---
# Asegúrate de que esta línea esté *después* de 'source $ZSH/oh-my-zsh.sh'
[[ ! -f ~/.config/zsh/.zshrc ]] || source ~/.config/zsh/.zshrc

# Configuración de usuario y otras cosas que Oh My Zsh no maneja por defecto.
# Puedes descomentar y personalizar estas secciones si es necesario.
# export MANPATH="/usr/local/man:$MANPATH"
# export LANG=en_US.UTF-8
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi
# export ARCHFLAGS="-arch $(uname -m)"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
