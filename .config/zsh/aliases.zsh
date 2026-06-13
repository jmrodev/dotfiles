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
alias feh='feh -. -Z'

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
# TERMINAL TIPS & HELP (PRO VERSION)
# ==========================================
function dot-help() {
    local category=$1
    local cyan="\033[1;36m"
    local green="\033[1;32m"
    local yellow="\033[1;33m"
    local blue="\033[1;34m"
    local reset="\033[0m"

    case $category in
        git)
            echo -e "${blue}--- 🌿 GIT & VERSION CONTROL ---${reset}"
            echo -e "${green}gs${reset}      : Status rápido del repositorio"
            echo -e "${green}glg${reset}     : Log visual con gráfico de ramas"
            echo -e "${green}gco${reset}     : Checkout (cambiar de rama/archivo)"
            echo -e "${green}gp / gpull${reset}: Push y Pull con rebase automático"
            echo -e "${green}gca${reset}     : Commit de todos los cambios con mensaje"
            echo -e "${green}lg${reset}      : Lanzar Lazygit (TUI profesional)"
            echo -e "${yellow}Submenú:${reset} Usa ${cyan}dot-help git-scripts${reset} para ver herramientas de GitHub."
            ;;
        git-scripts)
            echo -e "${blue}--- 🐙 GITHUB AUTOMATION SCRIPTS ---${reset}"
            echo -e "${green}gist_create${reset}: Crear un Gist desde un archivo"
            echo -e "${green}issue_list${reset} : Ver issues del repo actual"
            echo -e "${green}pr_create${reset}  : Crear Pull Request desde terminal"
            echo -e "${green}repo_view${reset}  : Abrir el repositorio en el navegador"
            echo -e "${cyan}Scripts en:${reset} ~/.config/zsh/git-scripts/"
            ;;
        sys)
            echo -e "${blue}--- ⚙️ SYSTEM & MAINTENANCE ---${reset}"
            echo -e "${green}actualizar${reset}: Sincroniza espejos y actualiza Pacman + AUR (yay)"
            echo -e "${green}libre${reset}     : Muestra memoria y limpia caché de la RAM"
            echo -e "${green}pacclean${reset}  : Elimina paquetes huérfanos del sistema"
            echo -e "${green}trim${reset}      : Ejecuta fstrim para optimizar tus discos SSD"
            echo -e "${green}infoi${reset}     : Resumen técnico del hardware (inxi)"
            ;;
        apps)
            echo -e "${blue}--- 🚀 APPLICATIONS & UTILS ---${reset}"
            echo -e "${green}edit / v${reset}   : Abre Neovim (tu editor principal)"
            echo -e "${green}r${reset}          : Ranger (Navegador de archivos en terminal)"
            echo -e "${green}youtube${reset}    : Descarga audio de YouTube en MP3"
            echo -e "${green}server${reset}     : Levanta un servidor web en la carpeta actual"
            echo -e "${green}weather${reset}    : Pronóstico del tiempo detallado"
            echo -e "${green}myip${reset}       : Muestra tu IP pública actual"
            ;;
        config)
            echo -e "${blue}--- 🛠️ DOTFILES MANAGEMENT ---${reset}"
            echo -e "${green}ds${reset}          : Estado de tus dotfiles (${cyan}config status${reset})"
            echo -e "${green}da <file>${reset}  : Añadir archivo al repo (${cyan}config add${reset})"
            echo -e "${green}dc \"msg\"${reset}   : Guardar cambios localmente (${cyan}config commit${reset})"
            echo -e "${green}dp${reset}          : Subir cambios a GitHub (${cyan}config push${reset})"
            echo -e "${green}upzsh${reset}       : Recargar toda la configuración de Zsh"
            echo -e "${yellow}Tip:${reset} Tienes ramas ${cyan}sway${reset} e ${cyan}i3wm${reset} independientes."
            ;;
        *)
            echo -e "${yellow}==========================================${reset}"
            echo -e "   🚀 ${blue}JMRO-DEV TERMINAL COMPANION${reset}   "
            echo -e "${yellow}==========================================${reset}"
            echo -e "Escribe ${green}dot-help <categoría>${reset} para ver detalles:"
            echo -e ""
            echo -e "  ${cyan}git${reset}         : Gestión de código y ramas"
            echo -e "  ${cyan}git-scripts${reset} : Automatización de GitHub (Gists, PRs)"
            echo -e "  ${cyan}sys${reset}         : Mantenimiento y Hardware"
            echo -e "  ${cyan}apps${reset}        : Aplicaciones, Web y Utilidades"
            echo -e "  ${cyan}config${reset}      : Control de este repositorio (Dotfiles)"
            echo -e ""
            echo -e "${blue}------------------------------------------${reset}"
            echo -e "💡 ${yellow}Tip:${reset} Usa ${green}dot-help apps${reset} para ver cómo descargar música o lanzar servers."
            ;;
    esac
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
