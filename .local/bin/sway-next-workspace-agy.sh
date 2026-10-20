#!/usr/bin/env bash

# Detectar socket activo de Sway
if [[ -z "$SWAYSOCK" ]]; then
    export SWAYSOCK=$(ls /run/user/$(id -u)/sway-ipc.*.sock 2>/dev/null | head -n 1)
fi

# 1. Si Kitty ya está abierto en Sway, enfocarlo
has_kitty=$(swaymsg -t get_tree | grep -q '"app_id": "kitty"' && echo "1" || echo "0")

if [[ "$has_kitty" == "1" ]]; then
    swaymsg '[app_id="kitty"] focus'
    if herdr status 2>/dev/null | grep -q "status: running"; then
        herdr tab create --label "agy" --focus 2>/dev/null || true
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

# Cambiar de workspace y lanzar Kitty con herdr
swaymsg "workspace number $target_ws; exec kitty -e herdr"
