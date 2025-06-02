# ~/.config/zsh/.zshrc 

# Cargar la configuración y el prompt por defecto de Manjaro si existen 

if [[ -f /usr/share/zsh/manjaro-zsh-config ]]; then   
	source /usr/share/zsh/manjaro-zsh-config 
fi 

if [[ -f /usr/share/zsh/manjaro-zsh-prompt ]]; then   
	source /usr/share/zsh/manjaro-zsh-prompt 
fi


# Fuente todos los módulos 

for f in ~/.config/zsh/*.zsh ~/.config/zsh/functions/*.zsh; do   
	[ -f "$f" ] && source "$f" 
done 
