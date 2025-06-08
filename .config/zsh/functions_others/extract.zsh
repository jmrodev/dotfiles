# ~/.config/zsh/functions/extract.zsh

# Extractor universal de archivos
function extract() {
    local clrstart="\033[1;34m"
    local clrend="\033[0m"

    if [[ "$#" -lt 1 ]]; then
        echo -e "${clrstart}Uso: extract <archivo> [directorio_destino] [v]${clrend}"
        return 1
    fi

    if [[ ! -e "$1" ]]; then
        echo -e "${clrstart}¡El archivo no existe!${clrend}"
        return 2
    fi

    local DESTDIR=${2:-.}
    local filename=$(basename "$1")

    case "${filename##*.}" in
        tar)
            echo -e "${clrstart}Extrayendo $1 a $DESTDIR: (tar sin comprimir)${clrend}"
            tar x${3}f "$1" -C "$DESTDIR"
            ;;
        gz|tgz)
            echo -e "${clrstart}Extrayendo $1 a $DESTDIR: (tar comprimido con gzip)${clrend}"
            tar x${3}fz "$1" -C "$DESTDIR"
            ;;
        xz)
            echo -e "${clrstart}Extrayendo $1 a $DESTDIR: (tar comprimido con xz)${clrend}"
            tar x${3}f -J "$1" -C "$DESTDIR"
            ;;
        bz2)
            echo -e "${clrstart}Extrayendo $1 a $DESTDIR: (tar comprimido con bzip2)${clrend}"
            tar x${3}fj "$1" -C "$DESTDIR"
            ;;
        zip)
            echo -e "${clrstart}Extrayendo $1 a $DESTDIR: (archivo zip)${clrend}"
            unzip "$1" -d "$DESTDIR"
            ;;
        rar)
            echo -e "${clrstart}Extrayendo $1 a $DESTDIR: (archivo rar)${clrend}"
            unrar x "$1" "$DESTDIR"
            ;;
        7z)
            echo -e "${clrstart}Extrayendo $1 a $DESTDIR: (archivo 7zip)${clrend}"
            7za e "$1" -o"$DESTDIR"
            ;;
        *)
            echo -e "${clrstart}¡Formato de archivo desconocido!${clrend}"
            return 5
            ;;
    esac
}
