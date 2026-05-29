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
alias r='ranger-cd'
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
alias nano='nano -w'

# --- PACKAGE MANAGEMENT (yay/pacman) ---
alias p='pacman'
alias pA='sudo pacman -A'
alias pO='sudo pacman-optimize'
alias pQ='pacman -Q'
alias pqi='pacman -Qi'
alias pR='sudo pacman -R'
alias prc='sudo pacman -Rc'
alias prs='sudo pacman -Rs'
alias prsc='sudo pacman -Rsc'
alias pS='sudo pacman -S'
alias psi='pacman -Si'
alias pqs='pacman -Qs'
alias psyu='sudo pacman -Syu'
alias pU='sudo pacman -U'
alias update='sudo pacman -Syu && yay -Syu --aur --noconfirm'
alias actualizar='yay -Syyyu --noconfirm'
alias install='yay -S'
alias remove='yay -Rns'
alias pacclean='sudo pacman -Rns $(pacman -Qdtq)'
alias ysyu='yay -Syu --aur --noconfirm'
alias clean='sudo pacman -Sc'
alias updater='psyu && ysyu && flatup && flatclean && flatclear && sudo pacman -Scc && rm -rf ~/.cache/*'

# --- TOOLS & APPS ---
alias lg='lazygit'
alias pt="env XDG_CURRENT_DESKTOP=GNOME /usr/lib/packettracer/packettracer.AppImage"
alias npm='pnpm'
alias npx='pnpm dlx'
alias sudo='sudo '
alias google-chrome='nohup google-chrome-stable --profile-directory=Default > /dev/null 2>&1 & disown'
alias google-chrome1='nohup google-chrome-stable --profile-directory="Profile 1" > /dev/null 2>&1 & disown'
alias google-chrome2='nohup google-chrome-stable --profile-directory="Profile 3" > /dev/null 2>&1 & disown'
alias youtube='yt-dlp --extract-audio --audio-format mp3'
alias myip='curl ifconfig.me'
alias weather='curl wttr.in'
alias upzsh='source ~/.zshrc'
alias net='nmap -sP 192.168.0.1/24'
alias server='python -m http.server 8000'
alias wifi='sudo modprobe brcmsmac'
alias translate='trans -t es'
alias metefrase='trans -t el'
alias doker='sudo systemctl start docker'
alias repo='sudo reflector --verbose -l 200 -p http --sort rate --save /etc/pacman.d/mirrorlist'

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
alias dlog='dotfiles log --oneline --decorate --graph --all'
alias dloga='dotfiles log --oneline --decorate --graph --all --date=relative --pretty=format:"%C(yellow)%h %C(cyan)%ad %C(green)%<(20)%an %C(reset)%s"'
alias dlogs='dotfiles log --pretty=format:"%C(yellow)%h %C(cyan)%ad %C(reset)%s" --date=short --graph'

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
alias gau='git add -u'
alias gca='git commit -a -m'
alias gf='git fetch'
alias gpull='git pull'
alias gpush='git push'
alias gm='git merge'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbi='git rebase -i'
alias gloga='git log --oneline --decorate --graph --all --date=relative --pretty=format:"%C(yellow)%h %C(cyan)%ad %C(green)%<(20)%an %C(reset)%s"'
alias current-branch='show_current_branch'
alias current-dotfiles-branch='show_current_dotfiles_branch'

# --- UTILS & HARDWARE ---
alias battery='upower -i /org/freedesktop/UPower/devices/battery_BAT0'
alias fullpower="powerprofilesctl set balanced && kwriteconfig6 --file powerdevilrc --group AC --group Display --key SleepTime 0 && kwriteconfig6 --file powerdevilrc --group AC --group SuspendSession --key suspendType 0 && qdbus6 org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement/Actions/SuspendSession setSuspendType 'Never'"
alias infoi='inxi -b'
alias freemem='sudo sysctl -w vm.drop_caches=3'
alias libre='free -h && sudo sysctl -w vm.drop_caches=3 && free -h'
alias trim='trimhome && trimroot'
alias trimhome='sudo fstrim -v /home'
alias trimroot='sudo fstrim -v /'
alias topmem='ps aux --sort=-%mem | head -n 10'
alias validarhtml='/home/jmro/.config/zsh/functions/validar.sh'
alias enose='pdfunite *.pdf out.pdf'
alias png2pdf='convert *.png out.pdf'

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
  if [ -z "$1" ]; then
    echo "Usage: trash <file_or_directory>..."
    return 1
  fi
  local trash_dir="$HOME/.local/share/Trash"
  mkdir -p "$trash_dir"
  for item in "$@"; do
    if [ -e "$item" ]; then
      local base_name=$(basename "$item")
      mv "$item" "$trash_dir/${base_name}_$(date +%Y%m%d%H%M%S)"
      echo "Moved '$item' to trash."
    fi
  done
}
alias rm='trash'

function safe_mv() {
  local destination="${@: -1}"
  [ -e "$destination" ] && [ "$destination" != "$1" ] && trash "$destination"
  command mv "$@"
}
alias mv='safe_mv'

function safe_cp() {
  local destination="${@: -1}"
  [ -e "$destination" ] && [ "$destination" != "$1" ] && trash "$destination"
  command cp "$@"
}
alias cp='safe_cp'

function list_trash() {
  ls -l "$HOME/.local/share/Trash"
}

function empty_trash() {
  echo -n "Permanently empty trash? (y/N) "
  read -k 1 confirm
  echo
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    rm -rf "$HOME/.local/share/Trash"/*
    echo "Trash emptied."
  fi
}
