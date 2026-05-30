# ==========================================
# UNIFIED ALIASES & FUNCTIONS (Repo SSoT)
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
alias trim='trimhome && trimroot'
alias trimhome='sudo fstrim -v /home'
alias trimroot='sudo fstrim -v /'

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
alias topmem='ps aux --sort=-%mem | head -n 10'
alias validarhtml='/home/jmro/.config/zsh/functions/validar.sh'
alias enose='pdfunite *.pdf out.pdf'
alias png2pdf='convert *.png out.pdf'

# ==========================================
# ADVANCED FUNCTIONS (EXACT REPO LOGIC)
# ==========================================

# Custom cd function to create directory if it doesn't exist
function _cd_with_prompt() {
  if [ -z "$1" ]; then # Check if $1 is empty
    builtin cd # Go to home directory if no argument
  elif [ -d "$1" ]; then
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

# Wrapper for the cd command to use the custom prompt function
function cd() {
  _cd_with_prompt "$@"
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

# ==========================================
# TERMINAL TIPS & HELP
# ==========================================
function dot-help() {
    local category=$1
    case $category in
        git)
            echo -e "\033[1;34m--- 🌿 GIT PRO ALIASES ---\033[0m"
            echo -e "\033[1;32mglg\033[0m     : Log visual (oneline + graph)"
            echo -e "\033[1;32mgs\033[0m      : Git Status"
            echo -e "\033[1;32mgp\033[0m      : Git Push"
            echo -e "\033[1;32mgpull\033[0m   : Git Pull"
            echo -e "\033[1;32mgco\033[0m     : Git Checkout"
            echo -e "\033[1;32mgca\033[0m     : Git Commit All"
            echo -e "\033[1;32mgrb\033[0m     : Git Rebase inteligente"
            echo -e "\033[1;32mgpusho\033[0m  : Push y set-upstream a rama actual"
            ;;
        sys)
            echo -e "\033[1;34m--- ⚙️ SYSTEM & MAINTENANCE ---\033[0m"
            echo -e "\033[1;32mactualizar\033[0m : Actualización total del sistema"
            echo -e "\033[1;32mpacclean\033[0m   : Limpiar paquetes huérfanos"
            echo -e "\033[1;32mlibre\033[0m      : Liberar memoria RAM (cache)"
            echo -e "\033[1;32mtrim\033[0m       : Optimizar SSD (fstrim)"
            echo -e "\033[1;32mtopmem\033[0m     : Procesos que más RAM consumen"
            echo -e "\033[1;32mbattery\033[0m    : Info detallada de batería"
            echo -e "\033[1;32minfoi\033[0m      : Resumen de hardware"
            ;;
        apps)
            echo -e "\033[1;34m--- 🚀 APPS & TOOLS ---\033[0m"
            echo -e "\033[1;32mlg\033[0m        : Lazygit"
            echo -e "\033[1;32mr\033[0m         : Ranger (Navegador visual)"
            echo -e "\033[1;32myoutube\033[0m   : Descargar MP3 de Youtube"
            echo -e "\033[1;32mweather\033[0m   : Clima en la terminal"
            echo -e "\033[1;32mdoker\033[0m     : Iniciar motor Docker"
            echo -e "\033[1;32mmyip\033[0m      : Ver tu IP pública"
            echo -e "\033[1;32mserver\033[0m    : Crear servidor HTTP en carpeta actual"
            ;;
        *)
            echo -e "\033[1;34m--- 🚀 DOTFILES MANAGEMENT CHEAT SHEET ---\033[0m"
            echo -e "\033[1;32mds\033[0m          : Ver cambios locales (dotfiles status)"
            echo -e "\033[1;32mda <archivo>\033[0m : Sumar archivos al repo (dotfiles add)"
            echo -e "\033[1;32mdc \"msj\"\033[0m     : Guardar cambios localmente (dotfiles commit)"
            echo -e "\033[1;32mdp\033[0m          : Subir todo a GitHub (dotfiles push)"
            echo -e "\033[1;32mupzsh\033[0m       : Recargar configuración (source)"
            echo -e ""
            echo -e "\033[1;34m--- 📂 CATEGORÍAS DISPONIBLES ---\033[0m"
            echo -e "Escribe \033[1;32mdot-help <categoría>\033[0m para ver alias de:"
            echo -e "• \033[1;32mgit\033[0m   : Atajos de Git"
            echo -e "• \033[1;32msys\033[0m   : Sistema y Mantenimiento"
            echo -e "• \033[1;32mapps\033[0m  : Aplicaciones y Herramientas"
            echo -e ""
            echo -e "\033[1;34m--- 🖥️ NUEVA PC (INSTALLER) ---\033[0m"
            echo -e "curl -sSL https://raw.githubusercontent.com/jmrodev/dotfiles/main/instalar.sh | bash"
            ;;
    esac
    echo -e "\033[1;34m------------------------------------------\033[0m"
}

# Actualización rápida de Dotfiles (Sincronización Espejo)
function dot-update() {
    echo -e "\033[1;34m--- 🔄 SINCRONIZANDO CON GITHUB (MODO ESPEJO) ---\033[0m"
    dotfiles fetch origin main
    dotfiles read-tree --reset -u FETCH_HEAD
    echo -e "\033[1;32m✅ Archivos de configuración actualizados.\033[0m"
    echo -e "\033[0;33mRecargando terminal...\033[0m"
    source ~/.zshrc
    dot-help
}
