# ~/.config/zsh/functions/title.zsh 

# Cambia título de la terminal a usuario@host:dir 

function set-title {   
	print -Pn "\e]0;%n@%m: %~\a" 
} 

precmd_functions+=(set-title)
