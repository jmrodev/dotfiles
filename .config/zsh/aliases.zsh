# Custom Git Aliases
alias gfogr='git fetch origin && git rebase '
alias gbr='git branch -r'
alias glg='git log --oneline --graph --all'
alias grb='git fetch origin && git rebase origin/$(git rev-parse --abbrev-ref HEAD)'
alias ..='cd ..'
alias ...='cd ../..'
alias la='eza -lah --git --icons'
alias ll='eza -lh --git --icons'
alias ls='eza --git --icons'
alias r='ranger-cd'
alias tree='eza --tree --icons'
alias gc='git commit -v'
alias gd='git diff'
alias gp='git push'
alias gs='git status'
alias gloga='git log --oneline --decorate --graph --all --date=relative --pretty=format:"%C(yellow)%h %C(cyan)%ad %C(green)%<(20)%an %C(reset)%s"'
alias gb='git branch'
alias gba='git branch -a'
alias gco='git checkout'
alias gau='git add -u'
alias gca='git commit -a -m'
alias gf='git fetch'
alias gpull='git pull'
alias gpush='git push'
alias gm='git merge'
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbi='git rebase -i'
alias da='dotfiles add'
alias dc='dotfiles commit -m'
alias dl='dotfiles log --oneline --decorate --graph --all'
alias dp='dotfiles push origin main'
alias ds='dotfiles status -s'
alias dlog='dotfiles log --oneline --decorate --graph --all'
alias dloga='dotfiles log --oneline --decorate --graph --all --date=relative --pretty=format:"%C(yellow)%h %C(cyan)%ad %C(green)%<(20)%an %C(reset)%s"'
alias dlogs='dotfiles log --pretty=format:"%C(yellow)%h %C(cyan)%ad %C(reset)%s" --date=short --graph'
alias battery='upower -i /org/freedesktop/UPower/devices/battery_BAT0'
alias infoi='inxi -b'
alias freemem='sudo sysctl -w vm.drop_caches=3'
alias libre='free -h && sudo sysctl -w vm.drop_caches=3 && free -h'
alias trim='trimhome && trimroot'
alias trimhome='sudo fstrim -v /home'
alias trimroot='sudo fstrim -v /'
alias clean='sudo pacman -Sc'
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
alias ysyu='yay -Syu --aur --noconfirm'
alias updater='psyu && ysyu && flatup && flatclean && flatclear && sudo pacman -Scc && rm -rf ~/.cache/*'

alias myip='curl ifconfig.me'
alias net='nmap -sP 192.168.0.1/24'
alias repo='sudo reflector --verbose -l 200 -p http --sort rate --save /etc/pacman.d/mirrorlist'
alias server='python -m http.server 8000'
alias wifi='sudo modprobe brcmsmac'
alias weather='curl wttr.in'
alias enose='pdfunite *.pdf out.pdf'
alias png2pdf='convert *.png out.pdf'
alias youtube='yt-dlp --extract-audio --audio-format mp3'
alias metefrase='trans -t el'
alias translate='trans -t es'
alias doker='sudo systemctl start docker'
alias upzsh='source ~/.zshrc'
alias current-branch='show_current_branch'
alias current-dotfiles-branch='show_current_dotfiles_branch'
alias df='df -h'
alias du='du -c -h'
alias free='free -m'
alias grep='grep --color=auto'
alias mkdir='mkdir -p -v'
alias nano='nano -w'
alias ping='ping -c 5'
alias npm='pnpm'
alias mem='free -h'
alias topmem='ps aux --sort=-%mem | head -n 10'
alias validarhtml='/home/jmro/.config/zsh/functions/validar.sh'
alias google-chrome='nohup google-chrome-stable --profile-directory=Default > /dev/null 2>&1 & disown'
alias google-chrome1='nohup google-chrome-stable --profile-directory="Profile 1" > /dev/null 2>&1 & disown'
alias google-chrome2='nohup google-chrome-stable --profile-directory="Profile 3" > /dev/null 2>&1 & disown'
alias cat='bat'

# Custom cd function to create directory if it doesn't exist
function cd() {
  if [ -d "$1" ]; then
    builtin cd "$@"
  else
    vared -p "Directory '$1' does not exist. Create it? (y/N) " -c create_dir_response
    if [[ "$create_dir_response" =~ ^[Yy]$ ]]; then
      mkdir -p "$1" && builtin cd "$@"
    else
      echo "Directory not created."
    fi
  fi
}

# Function to move files to trash
function trash() {
  if [ -z "$1" ]; then
    echo "Usage: trash <file_or_directory>..."
    return 1
  fi

  local trash_dir="$HOME/.local/share/Trash"
  mkdir -p "$trash_dir" # Ensure trash directory exists

  local files_to_trash=()
  local options=()

  for arg in "$@"; do
    if [[ "$arg" == -* ]]; then
      options+=("$arg") # Collect options, though we won't use them for mv
    else
      files_to_trash+=("$arg")
    fi
  done

  if [ ${#files_to_trash[@]} -eq 0 ]; then
    echo "No files or directories specified to trash."
    return 1
  fi

  for item in "${files_to_trash[@]}"; do
    if [ -e "$item" ]; then
      local base_name=$(basename "$item")
      local unique_name="${base_name}_$(date +%Y%m%d%H%M%S)"
      mv "$item" "$trash_dir/$unique_name"
      echo "Moved '$item' to trash as '$unique_name'"
    else
      echo "Error: '$item' not found."
    fi
  done
}

# Alias rm to use the trash function
alias rm='trash'

# Function to empty the trash
function empty_trash() {
  local trash_dir="$HOME/.local/share/Trash"
  if [ -d "$trash_dir" ]; then
    vared -p "Are you sure you want to permanently delete all items from the trash? (y/N) " -c confirm_empty_trash
    if [[ "$confirm_empty_trash" =~ ^[Yy]$ ]]; then
      rm -rf "$trash_dir"/* "$trash_dir"/.[!.]* # Delete all files and dotfiles
      echo "Trash emptied."
    else
      echo "Trash not emptied."
    fi
  else
    echo "Trash is already empty or does not exist."
  fi
}

# Function to safely move files, trashing existing destination files
function safe_mv() {
  local trash_dir="$HOME/.local/share/Trash"
  mkdir -p "$trash_dir" # Ensure trash directory exists

  local destination="${@: -1}" # Get the last argument as destination

  # Check if destination exists and is not the source
  if [ -e "$destination" ] && [ "$destination" != "$1" ]; then
    echo "Moving existing destination '$destination' to trash before move."
    trash "$destination"
  fi

  # Perform the actual move
  command mv "$@"
}

# Function to safely copy files, trashing existing destination files
function safe_cp() {
  local trash_dir="$HOME/.local/share/Trash"
  mkdir -p "$trash_dir" # Ensure trash directory exists

  local destination="${@: -1}" # Get the last argument as destination

  # Check if destination exists and is not the source
  if [ -e "$destination" ] && [ "$destination" != "$1" ]; then
    echo "Moving existing destination '$destination' to trash before copy."
    trash "$destination"
  fi

  # Perform the actual copy
  command cp "$@"
}

# Alias mv and cp to use the safe functions
alias mv='safe_mv'
alias cp='safe_cp'

# Function to list files in the trash
function list_trash() {
  local trash_dir="$HOME/.local/share/Trash"
  if [ -d "$trash_dir" ]; then
    echo "Files in trash ($trash_dir):"
    ls -l "$trash_dir"
  else
    echo "Trash is empty or does not exist."
  fi
}