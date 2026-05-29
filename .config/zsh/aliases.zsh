# ==========================================
# UNIFIED ALIASES (Dotfiles Managed)
# ==========================================

# --- SYSTEM & NAVIGATION ---
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ls='eza --color=always --group-directories-first --icons'
alias ll='eza -lah --color=always --group-directories-first --icons'
alias la='eza -a --icons'
alias lla='eza -la --icons --git'
alias lt='eza --tree --level=2 --icons'
alias tree='eza --tree --icons'
alias cat='bat --paging=never --style=plain'
alias top='btop'
alias df='df -h'
alias du='du -c -h'
alias free='free -m'
alias mem='free -h'
alias grep='grep --color=auto'
alias mkdir='mkdir -p -v'
alias ping='ping -c 5'
alias edit='nvim'
alias vim='nvim'
alias vi='nvim'
alias v='nvim'

# --- PACKAGE MANAGEMENT (yay/pacman) ---
alias p='pacman'
alias pS='sudo pacman -S'
alias pR='sudo pacman -R'
alias pQ='pacman -Q'
alias psyu='sudo pacman -Syu'
alias update='yay -Syyyu --noconfirm'
alias actualizar='yay -Syyyu --noconfirm'
alias install='yay -S'
alias remove='yay -Rns'
alias pacclean='sudo pacman -Rns $(pacman -Qdtq)'
alias ysyu='yay -Syu --aur --noconfirm'

# --- TOOLS & APPS ---
alias lg='lazygit'
alias pt="env XDG_CURRENT_DESKTOP=GNOME /usr/lib/packettracer/packettracer.AppImage"
alias npm='pnpm'
alias npx='pnpm dlx'
alias sudo='sudo '
alias google-chrome='nohup google-chrome-stable --profile-directory=Default > /dev/null 2>&1 & disown'
alias youtube='yt-dlp --extract-audio --audio-format mp3'
alias myip='curl ifconfig.me'
alias weather='curl wttr.in'
alias upzsh='source ~/.zshrc'

# --- SSH & REMOTE ---
alias cima='ssh_tmux cima-ext'
alias peques='ssh_tmux peques'
alias rpi-ext='ssh_tmux rpi-ext'
alias rpi='ssh_tmux rpi'

# --- DOTFILES BARE REPO MANAGEMENT ---
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias da='dotfiles add'
alias dc='dotfiles commit -m'
alias ds='dotfiles status -s'
alias dp='dotfiles push origin main'
alias dl='dotfiles log --oneline --decorate --graph --all'

# --- GIT (REPO MODULAR) ---
alias gfogr='git fetch origin && git rebase '
alias gbr='git branch -r'
alias glg='git log --oneline --graph --all'
alias grb='git fetch origin && git rebase origin/$(git rev-parse --abbrev-ref HEAD)'
alias gc='git commit -v'
alias gd='git diff'
alias gp='git push'
alias gs='git status'
alias gco='git checkout'
alias gpull='git pull'
alias gpush='git push'

# --- UTILS & HARDWARE ---
alias battery='upower -i /org/freedesktop/UPower/devices/battery_BAT0'
alias fullpower="powerprofilesctl set balanced && kwriteconfig6 --file powerdevilrc --group AC --group Display --key SleepTime 0 && kwriteconfig6 --file powerdevilrc --group AC --group SuspendSession --key suspendType 0 && qdbus6 org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement/Actions/SuspendSession setSuspendType 'Never'"
alias freemem='sudo sysctl -w vm.drop_caches=3'

# --- CUSTOM FUNCTIONS (MIGRATED FROM REPO) ---

# cd with prompt to create dir
function cd() {
  if [ -z "$1" ]; then
    builtin cd
  elif [ -d "$1" ]; then
    builtin cd "$@"
  else
    echo -n "Directory '$1' does not exist. Create it? (y/N) "
    read -k 1 create_dir_response
    echo
    if [[ "$create_dir_response" =~ ^[Yy]$ ]]; then
      mkdir -p "$1" && builtin cd "$@"
    else
      echo "Directory not created."
    fi
  fi
}

# Trash Management (Safety first)
function trash() {
  local trash_dir="$HOME/.local/share/Trash"
  mkdir -p "$trash_dir"
  for item in "$@"; do
    if [ -e "$item" ]; then
      mv "$item" "$trash_dir/$(basename "$item")_$(date +%Y%m%d%H%M%S)"
    fi
  done
}
alias rm='trash'

function safe_mv() {
  [ -e "${@: -1}" ] && trash "${@: -1}"
  command mv "$@"
}
alias mv='safe_mv'

function safe_cp() {
  [ -e "${@: -1}" ] && trash "${@: -1}"
  command cp "$@"
}
alias cp='safe_cp'
