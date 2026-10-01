#!/usr/bin/env bash

# Detectar socket activo de Sway
if [[ -z "$SWAYSOCK" ]]; then
    export SWAYSOCK=$(ls /run/user/1000/sway-ipc.*.sock 2>/dev/null | head -n 1)
fi

# 1. Verificar si ya existe una ventana de Kitty en Sway
has_kitty=$(swaymsg -t get_tree | grep -q '"app_id": "kitty"' && echo "1" || echo "0")

if [[ "$has_kitty" == "1" ]]; then
    # Enfocar la ventana existente de Kitty
    swaymsg '[app_id="kitty"] focus'
    
    # Comprobar si existe la ventana 'agycode' en Tmux
    if tmux list-windows -F '#{window_name}' 2>/dev/null | grep -qx 'agycode'; then
        tmux select-window -t agycode 2>/dev/null
    else
        # Si no existe, crear una ventana nueva de Tmux para agycode
        tmux new-window -n agycode "agycode" 2>/dev/null || tmux new-window -n agycode 2>/dev/null
    fi
    exit 0
fi

# 2. Si Kitty NO está abierto, buscar el próximo workspace vacío (1 al 10)
used_ws=$(swaymsg -t get_workspaces | jq -r '.[].num')

target_ws=""
for i in {1..10}; do
    if ! echo "$used_ws" | grep -qx "$i"; then
        target_ws="$i"
        break
    fi
done

if [[ -z "$target_ws" ]]; then
    max_ws=$(echo "$used_ws" | sort -n | tail -n 1)
    target_ws=$((max_ws + 1))
fi

# Cambiar de workspace y lanzar Kitty con Tmux corriendo agycode
swaymsg "workspace number $target_ws; exec kitty -e tmux new-session -A -s main -n agycode agycode"
