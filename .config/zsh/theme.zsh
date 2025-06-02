# ~/.config/zsh/theme.zsh 

# Carga Powerlevel10k si está instalado 

if [[ -f ~/.powerlevel10k/powerlevel10k.zsh-theme ]]; then   
	source ~/.powerlevel10k/powerlevel10k.zsh-theme
# POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true  
else   
# Fallback simple si no está p10k   
	PROMPT='%F{cyan}%n@%m %1~ %# %f' 
fi 
