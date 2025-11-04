# ~/.config/zsh/plugins.zsh 

# fzf 
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh 

# thefuck 
# eval "$(thefuck --alias)" 
alias fuck='thefuck --alias'

# ranger_cd function
function ranger-cd {     
	local temp_file="$(mktemp -t "ranger_cd.XXXXXXXXXX")"     
	ranger --choosedir="$temp_file" "${@:-.}"     
	if [ -f "$temp_file" ] && [ -s "$temp_file" ]; then         	
		_ranger_cd_active=1 builtin cd -- "$(cat "$temp_file")"
		unset _ranger_cd_active     
	fi     
	command rm -f -- "$temp_file" 	
}

# Auto-cargar funciones personalizadas
fpath=(
~/.config/zsh/functions
~/.config/zsh/functions/git
$fpath

)
