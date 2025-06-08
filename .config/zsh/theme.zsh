# ~/.config/zsh/theme.zsh 

# Carga Powerlevel10k si está instalado 
if [[ -f ~/.powerlevel10k/powerlevel10k.zsh-theme ]]; then   
	source ~/.powerlevel10k/powerlevel10k.zsh-theme
# POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true  
else   
	# Fallback mejorado si no está p10k   
	autoload -U colors && colors
	PROMPT='%{$fg[cyan]%}%n@%m %{$fg[blue]%}%1~ %{$fg[green]%}%# %{$reset_color%}'
fi 
