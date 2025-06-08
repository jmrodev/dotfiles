# ~/.config/zsh/functions/calc.zsh

# Calculadora simple
function calc() {
    if command -v bc &>/dev/null; then
        echo "scale=3; $*" | bc -l
    else
        awk "BEGIN { print $* }"
    fi
}
