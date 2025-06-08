# ~/.config/zsh/functions/dirsize.zsh

# Ver tamaños de directorios
function dirsize() {
    du -shx * .[a-zA-Z0-9_]* 2>/dev/null | \
    egrep '^ *[0-9.]*[MG]' | \
    sort -n > /tmp/list
    
    echo "=== Directorios en MB ==="
    egrep '^ *[0-9.]*M' /tmp/list
    echo "=== Directorios en GB ==="
    egrep '^ *[0-9.]*G' /tmp/list
    
    rm -f /tmp/list
}
