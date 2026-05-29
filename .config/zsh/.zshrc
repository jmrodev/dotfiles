# ~/.config/zsh/.zshrc
# Entry point modular gestionado por dotfiles

# --- FASTFETCH ---
fastfetch

# Enable Powerlevel10k instant prompt.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Definición de la función dotfiles
dotfiles() {
    /usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME "$@"
}

# --- OH MY ZSH ---
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins de Oh My Zsh
plugins=(
    git sudo z zsh-autosuggestions fast-syntax-highlighting zsh-autocomplete archlinux extract web-search copyfile dirhistory
)

[[ -f "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

# --- CONFIGURACIÓN MODULAR ---
ZDOTDIR=${ZDOTDIR:-$HOME/.config/zsh}

# Carga de archivos en orden
config_files=(
    options.zsh
    keybindings.zsh
    plugins.zsh
)

for config_file in "${config_files[@]}"; do
    [[ -f "$ZDOTDIR/$config_file" ]] && source "$ZDOTDIR/$config_file"
done

# Carga de alias (Repo manda)
[[ -f "$ZDOTDIR/aliases.zsh" ]] && source "$ZDOTDIR/aliases.zsh"

# Carga de scripts dinámicos
[[ -f "$ZDOTDIR/functions/git/git_dynamic_aliases" ]] && source "$ZDOTDIR/functions/git/git_dynamic_aliases"

# --- CARGA DE FUNCIONES (fpath) ---
fpath=(
  ~/.config/zsh/functions/utils
  ~/.config/zsh/functions/git
  ~/.config/zsh/functions/fileops
  ~/.config/zsh/functions/systemd
  $fpath
)
autoload -Uz calc ff top10 dirsize compress extract up urlencode title \
  swap lowercase start restart stop enable status disable \
  gup gupm gunwip gwip gcbp gdelb git_current_branch dotfiles_current_branch \
  git_feature_start git_feature_finish dotfiles_add_select git-publish gsync gforce gpub gstart gupdate

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
unset config_files config_file
