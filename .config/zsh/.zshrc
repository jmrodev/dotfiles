# ~/.config/zsh/.zshrc 

# 1. CARGAR FUNCIONES DE GIT PRIMERO
# Esto asegura que todas las funciones estén disponibles antes de evaluar aliases
#if [[ -d "$HOME/.config/zsh/functions/git" ]]; then
#    for func in "$HOME"/.config/zsh/functions/git/*.zsh; do
#       if [[ -r "$func" ]]; then
#            source "$func"
#        fi
#    done
#fi

# 2. CARGAR ALIASES DESPUÉS
# Los aliases pueden referenciar las funciones cargadas arriba
if [[ -f "$HOME/.config/zsh/aliases.zsh" ]]; then
    source "$HOME/.config/zsh/aliases.zsh"
fi

# 3. VERIFICACIÓN OPCIONAL (puedes comentar esto después de verificar que funciona)
# Verificar que las funciones críticas estén cargadas
#if ! command -v git_current_branch &> /dev/null; then
#    echo "⚠️  Advertencia: La función git_current_branch no está cargada"
#fi

#if ! command -v dotfiles_current_branch &> /dev/null; then
#    echo "⚠️  Advertencia: La función dotfiles_current_branch no está cargada"
#fi



# Cargar la configuración y el prompt por defecto de Manjaro si existen 

if [[ -f /usr/share/zsh/manjaro-zsh-config ]]; then   
	source /usr/share/zsh/manjaro-zsh-config 
fi 

if [[ -f /usr/share/zsh/manjaro-zsh-prompt ]]; then   
	source /usr/share/zsh/manjaro-zsh-prompt 
fi


# Fuente todos los módulos 

#for f in ~/.config/zsh/*.zsh ~/.config/zsh/functions/*.zsh; do   
#	[ -f "$f" ] && source "$f" 
#done 

for f in ~/.config/zsh/*.zsh; do   
	[ -f "$f" ] && source "$f" 
done 

