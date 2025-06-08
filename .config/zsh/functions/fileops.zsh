# ~/.config/zsh/functions/fileops.zsh

# Intercambiar nombres de dos archivos
function swap() {
    local TMPFILE="tmp.$$"

    [[ $# -ne 2 ]] && echo "swap: necesita 2 argumentos" && return 1
    [[ ! -e $1 ]] && echo "swap: $1 no existe" && return 1
    [[ ! -e $2 ]] && echo "swap: $2 no existe" && return 1

    mv "$1" "$TMPFILE"
    mv "$2" "$1"
    mv "$TMPFILE" "$2"
    echo "Archivos intercambiados: $1 <-> $2"
}

# Convertir nombres de archivo a minúsculas
function lowercase() {
    for file; do
        local filename=${file##*/}
        local dirname=${file%/*}
        [[ "$dirname" == "$filename" ]] && dirname="."
        
        local nf=$(echo "$filename" | tr A-Z a-z)
        local newname="${dirname}/${nf}"
        
        if [[ "$nf" != "$filename" ]]; then
            mv "$file" "$newname"
            echo "lowercase: $file --> $newname"
        else
            echo "lowercase: $file sin cambios."
        fi
    done
}
