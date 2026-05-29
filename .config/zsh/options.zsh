# ~/.config/zsh/options.zsh

# --- HISTORIAL (Optimizado Senior) ---
HISTFILE=~/.histfile
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS          # No guardar si es igual al anterior
setopt HIST_IGNORE_ALL_DUPS      # Borrar duplicados previos
setopt HIST_SAVE_NO_DUPS         # No guardar duplicados en el archivo
setopt HIST_REDUCE_BLANKS        # Eliminar espacios sobrantes
setopt INC_APPEND_HISTORY        # Actualizar historial inmediatamente
setopt SHARE_HISTORY             # Compartir historial entre sesiones
setopt EXTENDED_HISTORY          # Guardar timestamp del comando
setopt HIST_FIND_NO_DUPS         # No mostrar duplicados al buscar hacia atrás
setopt hist_verify               # Verificar comandos del historial antes de ejecutar

# --- NAVEGACIÓN ---
setopt autocd                   # cd automático si escribes la ruta
setopt auto_pushd                # cd guarda en el stack
setopt pushd_ignore_dups         # No duplicar directorios en el stack
setopt pushd_minus               # Intercambiar + y - para pushd
setopt cdable_vars               # Permitir cd a variables

# --- ESTÉTICA Y COMPORTAMIENTO ---
setopt correct                  # Autocorrección de comandos
setopt no_beep                   # Silencio, por favor
setopt extended_glob             # Comodines avanzados
setopt nocaseglob                # Búsqueda sin distinguir mayúsculas
setopt multios                   # Múltiples redirecciones
setopt prompt_subst              # Sustitución en el prompt

# --- AUTOCOMPLETADO (IDE STYLE) ---
zstyle ':completion:*' menu select 
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%F{yellow}-- %d --%f%b'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' tag-order 'aliases' 'functions' 'commands' 'builtins' 'local-directories' 'directories' 'files'
zstyle ':completion:*' group-order aliases functions commands builtins local-directories directories files
