# ~/.config/zsh/plugins.zsh 

# --- FZF ---
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh 

# --- THEFUCK ---
# alias fuck='thefuck --alias'

# --- ZSH-AUTOCOMPLETE (Ajustes IDE) ---
zstyle ':autocomplete:*' delay 0.8
zstyle ':autocomplete:*' list-lines 50
zstyle ':autocomplete:tab:*' insert-unambiguous yes

# --- RANGER CD ---
function ranger-cd {     
        local temp_file="$(mktemp -t "ranger_cd.XXXXXXXXXX")"     
        ranger --choosedir="$temp_file" "${@:-.}"     
        if [ -f "$temp_file" ] && [ -s "$temp_file" ]; then         
                _ranger_cd_active=1 builtin cd -- "$(cat "$temp_file")"
                unset _ranger_cd_active     
        fi     
        command rm -f -- "$temp_file" 
}
alias r='ranger-cd'

# --- SSH TMUX (Anti-cortes Wi-Fi) ---
ssh_tmux() {
    ssh -t "$1" "tmux attach-session -t main || tmux new-session -s main"
}
