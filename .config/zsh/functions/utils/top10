# ~/.config/zsh/functions/top10.zsh

# Ver los 10 comandos más usados
function top10() {
    history | awk '{a[$2]++} END{for(i in a){print a[i] " " i}}' | sort -rn | head
}
