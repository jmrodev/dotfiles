# ~/.config/zsh/plugins.zsh 

# fzf 
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh 

# zsh-autosuggestions 
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
 
# zsh-syntax-highlighting (debe ir al final)
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 

# thefuck 
eval "$(thefuck --alias)" 

# ranger_cd function
function ranger-cd {     
	local temp_file="$(mktemp -t "ranger_cd.XXXXXXXXXX")"     
	ranger --choosedir="$temp_file" "${@:-.}"     
	if [ -f "$temp_file" ] && [ -s "$temp_file" ]; then         	
		cd -- "$(cat "$temp_file")"     
	fi     
	rm -f -- "$temp_file" 	
}

# Auto-cargar funciones personalizadas
fpath=(
~/.config/zsh/functions
~/.config/zsh/functions/git
$fpath

)
