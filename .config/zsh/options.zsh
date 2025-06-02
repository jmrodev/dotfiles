# ~/.config/zsh/options.zsh 

setopt autocd 
setopt correct 
setopt no_beep 
setopt histignoredups 
setopt share_history 
setopt extended_glob 
setopt nocaseglob 

# Zstyle 
zstyle ':completion:*' menu select 
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' 
