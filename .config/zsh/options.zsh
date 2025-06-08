# ~/.config/zsh/options.zsh

# Opciones básicas
setopt autocd 
setopt correct 
setopt no_beep 
setopt histignoredups 
setopt share_history 
setopt extended_glob 
setopt nocaseglob 

# Navegación mejorada
setopt auto_pushd           # Hacer cd pushd automáticamente
setopt pushd_ignore_dups    # No duplicar directorios en la pila
setopt pushd_minus          # Intercambiar + y - para pushd
setopt cdable_vars          # Permitir cd a variables

# Otras mejoras
setopt multios              # Permitir múltiples redirecciones
setopt prompt_subst         # Permitir sustitución en prompt
setopt hist_verify          # Verificar comandos del historial antes de ejecutar

# Zstyle 
zstyle ':completion:*' menu select 
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' 
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
