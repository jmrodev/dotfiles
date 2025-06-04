#!/bin/bash

# Ruta al script original shutdown_menu
SHUTDOWN_SCRIPT="/home/jmro/.config/i3blocks/i3blocks-contrib/shutdown_menu/shutdown_menu"

# Si la variable de entorno BLOCK_BUTTON está definida, significa que i3blocks lo ejecutó por un clic
if [ -n "$BLOCK_BUTTON" ]; then
    # Ejecuta el script original para que abra Rofi/Zenity
    "$SHUTDOWN_SCRIPT"
else
    # Si no es un clic, simplemente imprime la etiqueta para la barra
    # Puedes usar un ícono de FontAwesome si tu fuente lo soporta
    # Por ejemplo: echo ""
    echo "APAGADO"
fi
