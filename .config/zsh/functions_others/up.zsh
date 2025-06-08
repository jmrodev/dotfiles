# ~/.config/zsh/functions/up.zsh

# Navegar hacia arriba múltiples directorios
function up() {
    local d=""
    local limit=${1:-1}
    
    for ((i=1; i <= limit; i++)); do
        d="$d/.."
    done
    
    d=${d#/}
    cd ${d:=..}
}
