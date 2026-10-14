#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
# antigravity-cli se excluye: se mantiene la instalacion oficial via script (~/.gemini/antigravity-cli/bin)
PAQUETES=($(awk '{print $1}' "$DIR/aur_packages.txt" | grep -vFx -f <(pacman -Qq) | grep -vFx "antigravity-cli"))

echo "Paquetes faltantes a instalar (${#PAQUETES[@]}):"
echo "${PAQUETES[*]}"
echo ""

yay -S --needed "${PAQUETES[@]}"
