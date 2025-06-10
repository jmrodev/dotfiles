# ~/.config/zsh/aliases.zsh 
# Alias comunes y prácticos 

# Navegación y archivos
alias r='ranger-cd'
alias tree='eza --tree --icons'
alias ls='eza --git --icons'
alias ll='eza -lh --git --icons' 
alias la='eza -lah --git --icons' 
alias ..='cd ..' 
alias ...='cd ../..'

# Git shortcuts
alias gs='git status' 
alias gd='git diff' 
alias gp='git push' 
alias gc='git commit -v'

# --- Status & Log ---
alias glog='git log --oneline --decorate --graph --all' # Log compacto y gráfico
alias gloga='git log --oneline --decorate --graph --all --date=relative --pretty=format:"%C(yellow)%h %C(cyan)%ad %C(green)%<(20)%an %C(reset)%s"' # Log más detallado y coloreado
alias glogs='git log --pretty=format:"%C(yellow)%h %C(cyan)%ad %C(reset)%s" --date=short --graph' # Log corto y gráfico
alias gss='git status -s' # Status corto (útil para scripts)

# --- Branching ---
alias gb='git branch'
alias gba='git branch -a' # Mostrar todas las ramas (locales y remotas)
alias gbc='git checkout -b' # Crear y cambiar a una nueva rama
alias gco='git checkout'
alias gcm='git checkout main' # o master si usas ese nombre
alias gcd='git checkout develop' # si usas una rama develop

# --- Staging & Committing ---
alias gaa='git add -A' # Añadir todos los cambios (nuevos, modificados, eliminados)
alias gau='git add -u' # Añadir solo archivos modificados y eliminados (no nuevos)
alias gca='git commit -a -m' # Añadir todos los archivos trackeados y hacer commit
alias gcam='git commit --amend -m' # Modificar el último commit con un nuevo mensaje
alias gcan='git commit --amend --no-edit' # Modificar el último commit sin cambiar el mensaje (útil si solo añades archivos)
alias gundo='git reset --soft HEAD^' # Deshacer el último commit, manteniendo los cambios en staging
alias ghardundo='git reset --hard HEAD^' # Deshacer el último commit y descartar los cambios (¡CUIDADO!)

# --- Remote Operations ---
alias gf='git fetch'
alias gfa='git fetch --all --prune' # Fetch de todos los remotos y limpia ramas remotas borradas
alias gpull='git pull'
alias gpullr='git pull --rebase' # Pull con rebase en lugar de merge
alias gpush='git push'
alias gpushf='git push --force-with-lease' # Push forzado más seguro que --force (¡AÚN ASÍ, CUIDADO!)
# REMOVIDO: alias gpusho='git push -u origin $(git_current_branch)' 
# REEMPLAZADO POR: función gpusho() en git_dynamic_aliases.zsh

# --- Merging & Rebasing ---
alias gm='git merge'
alias gmt='git mergetool' # Abrir herramienta de merge
alias grb='git rebase'
alias grba='git rebase --abort' # Abortar rebase
alias grbc='git rebase --continue' # Continuar rebase
alias grbi='git rebase -i' # Rebase interactivo

# --- Stash ---
alias gst='git stash'
alias gstp='git stash pop'
alias gstl='git stash list'
alias gsta='git stash apply'
alias gstd='git stash drop'

# --- Tags ---
alias gt='git tag'
alias gta='git tag -a' # Crear tag anotado
alias gtd='git tag -d' # Borrar tag

# --- Clean ---
alias gclean='git clean -fd' # Borrar archivos no trackeados (¡CUIDADO!)
alias gcleanx='git clean -fdx' # Borrar archivos no trackeados e ignorados (¡AÚN MÁS CUIDADO!)

# --- Dotfiles Management (tus alias base) ---
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
alias dl='dotfiles log --oneline --decorate --graph --all' # Mejorando tu 'dl' original
alias ds='dotfiles status -s' # Status corto para dotfiles
alias da='dotfiles add' # Ya lo tienes, pero como referencia
alias dc='dotfiles commit -m' # Ya lo tienes
alias dp='dotfiles push origin main' # Ya lo tienes

# --- Dotfiles: Status & Log (derivados de los alias de Git) ---
alias dlog='dotfiles log --oneline --decorate --graph --all' # Equivalente a glog
alias dloga='dotfiles log --oneline --decorate --graph --all --date=relative --pretty=format:"%C(yellow)%h %C(cyan)%ad %C(green)%<(20)%an %C(reset)%s"' # Equivalente a gloga
alias dlogs='dotfiles log --pretty=format:"%C(yellow)%h %C(cyan)%ad %C(reset)%s" --date=short --graph' # Equivalente a glogs
alias dss='dotfiles status -s' # Equivalente a gss (ds ya es similar)

# --- Dotfiles: Branching ---
alias db='dotfiles branch'
alias dba='dotfiles branch -a'
alias dbc='dotfiles checkout -b'
alias dco='dotfiles checkout'
# Nota: Para dotfiles, usualmente trabajas en 'main' o 'master', así que dcm/dcd podrían no ser tan necesarios
# alias dcm='dotfiles checkout main'

# --- Dotfiles: Staging & Committing ---
alias daa='dotfiles add -A'
alias dau='dotfiles add -u'
alias dca='dotfiles commit -a -m'
alias dcam='dotfiles commit --amend -m'
alias dcan='dotfiles commit --amend --no-edit'
alias dundo='dotfiles reset --soft HEAD^'
alias dhardundo='dotfiles reset --hard HEAD^' # ¡MUCHO CUIDADO CON ESTE PARA DOTFILES!

# --- Dotfiles: Remote Operations ---
alias dfetch='dotfiles fetch' # 'df' podría colisionar con el comando 'df' del sistema
alias dfa='dotfiles fetch --all --prune'
alias dpull='dotfiles pull' # Generalmente no haces pull directamente a tu work-tree de dotfiles así, es más un fetch y luego checkout o merge si tienes conflictos o cambios remotos.
alias dpullr='dotfiles pull --rebase'
# alias dpush='dotfiles push' # 'dp' ya hace esto a origin main
alias dpushf='dotfiles push --force-with-lease' # ¡CUIDADO!
# NOTA: dpusho está disponible como función en git_dynamic_aliases.zsh

# --- Dotfiles: Merging & Rebasing (menos comunes para dotfiles, pero posibles) ---
alias dm='dotfiles merge'
alias dmt='dotfiles mergetool'
alias drb='dotfiles rebase'
alias drba='dotfiles rebase --abort'
alias drbc='dotfiles rebase --continue'
alias drbi='dotfiles rebase -i'

# --- Dotfiles: Stash (puede ser útil si editas dotfiles y necesitas cambiar de rama temporalmente) ---
alias dst='dotfiles stash'
alias dstp='dotfiles stash pop'
alias dstl='dotfiles stash list'
alias dsta='dotfiles stash apply'
alias dstd='dotfiles stash drop'

# --- Dotfiles: Tags (útil para marcar versiones de tu configuración) ---
alias dt='dotfiles tag'
alias dta='dotfiles tag -a'
alias dtd='dotfiles tag -d'

# --- Dotfiles: Clean (¡EXTREMO CUIDADO CON ESTOS EN TUS DOTFILES!) ---
# No recomiendo alias directos para 'clean' en dotfiles sin una confirmación muy explícita,
# ya que podrías borrar archivos de configuración que no están en Git pero que son importantes.
# Si decides hacerlo, sé muy consciente de lo que hacen.
# alias dclean='dotfiles clean -fd'
# alias dcleanx='dotfiles clean -fdx'

# Información del sistema
alias bat='acpi'
alias battery='upower -i /org/freedesktop/UPower/devices/battery_BAT0'
alias infoi='inxi -b'

# Limpieza de memoria
alias freemem='sudo sysctl -w vm.drop_caches=3'
alias libre='free -h && sudo sysctl -w vm.drop_caches=3 && free -h'

# Trim SSD
alias trimroot='sudo fstrim -v /'
alias trimhome='sudo fstrim -v /home'
alias trim='trimhome && trimroot'

# Pacman aliases
alias p='pacman' 
alias update='sudo pacman -Syu && yay -Syu --aur --noconfirm'
alias pQ='pacman -Q'
alias pqs='pacman -Qs' 
alias pqi='pacman -Qi'
alias pS='sudo pacman -S'
alias psyu='sudo pacman -Syu'
alias clean='sudo pacman -Sc'
alias psi='pacman -Si'
alias pR='sudo pacman -R'
alias prc='sudo pacman -Rc'
alias prs='sudo pacman -Rs'
alias prsc='sudo pacman -Rsc'
alias pA='sudo pacman -A'
alias pU='sudo pacman -U'
alias pO='sudo pacman-optimize'

# AUR alias
alias ysyu='yay -Syu --aur --noconfirm'

# Flatpak aliases
alias flatup='sudo flatpak update'
alias flatclean='sudo flatpak uninstall --unused'
alias flatclear='sudo rm -rf /var/tmp/flatpak-cache*'

# Sistema completo
alias updater='psyu && ysyu && flatup && flatclean && flatclear && sudo pacman -Scc && rm -rf ~/.cache/*'

# Red y servidor
alias net='nmap -sP 192.168.0.1/24'
alias server='python -m http.server 8000'
alias myip='curl ifconfig.me'
alias repo='sudo reflector --verbose -l 200 -p http --sort rate --save /etc/pacman.d/mirrorlist'
alias wifi='sudo modprobe brcmsmac'

# Información útil
alias weather='curl wttr.in'
alias covid='curl snf-878293.vm.okeanos.grnet.gr'

# Archivos y multimedia
alias enose='pdfunite *.pdf out.pdf'
alias png2pdf='convert *.png out.pdf'
alias youtube='yt-dlp --extract-audio --audio-format mp3'
alias mega='megacopy --local megatools --remote /Root/Uploads'

# Traducción
alias translate='trans -t es'
alias metefrase='trans -t el'

# Docker y servicios
alias doker='sudo systemctl start docker'

# Recargar configuración
alias upzsh='source ~/.zshrc'

# Comandos mejorados
alias df='df -h'
alias du='du -c -h'
alias free='free -m'
alias grep='grep --color=auto'
alias mkdir='mkdir -p -v'
alias ping='ping -c 5'
alias nano='nano -w'

# Funciones de ayuda para información de ramas (disponibles como comandos)
alias current-branch='show_current_branch'
alias current-dotfiles-branch='show_current_dotfiles_branch'
