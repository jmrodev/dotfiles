# ~/.config/zsh/functions/compress.zsh

# Comprimir archivos
function compress() {
    if [[ -n "$1" ]]; then
        local FILE=$1
        case $FILE in
            *.tar ) shift && tar cf $FILE $* ;;
            *.tar.bz2 ) shift && tar cjf $FILE $* ;;
            *.tar.gz ) shift && tar czf $FILE $* ;;
            *.tgz ) shift && tar czf $FILE $* ;;
            *.zip ) shift && zip $FILE $* ;;
            *.rar ) shift && rar $FILE $* ;;
            *) echo "Formato no soportado" ;;
        esac
    else
        echo "Uso: compress <archivo.tar.gz> ./directorio ./archivo"
    fi
}
