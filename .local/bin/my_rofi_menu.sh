#!/bin/bash

# Define tu emulador de terminal preferido.
TERMINAL="xfce4-terminal" # <-- ¡IMPORTANTE! Cambia esto a tu terminal (ej. kitty, xfce4-terminal, gnome-terminal)

# Opciones que se mostrarán en el menú Rofi.
# Cada línea es una entrada. El texto de la izquierda es lo que se muestra,
# y el texto a la derecha es el comando o descripción.
# Puedes añadir más o modificar las existentes.
OPTIONS="htop\nnvim\nFirefox\nTerminator\nSpotify\nExit i3\nPower Menu"

# Muestra el menú en Rofi y captura la elección del usuario.
CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -p "My Custom Menu:")

# Ejecuta un comando basado en la elección del usuario.
case "$CHOICE" in
    "htop")
        # Abre htop en una nueva ventana de terminal. El '&' permite que el script continúe.
        "$TERMINAL" -e htop &
        ;;
    "nvim")
        # Abre Neovim en una nueva ventana de terminal.
        "$TERMINAL" -e nvim &
        ;;
    "Firefox")
        # Lanza el navegador Firefox.
        firefox &
        ;;
    "Terminal")
        # Lanza el emulador de terminal Terminator. Cambia si usas otro.
        xfce4-terminal &
        ;;
    "Spotify")
        # Lanza la aplicación Spotify. Asegúrate de que el ejecutable sea 'spotify' o el correcto.
        spotify &
        ;;
    "Exit i3")
        # Cierra la sesión de i3. Esto te llevará de vuelta a tu gestor de inicio de sesión.
        i3-msg exit
        ;;
    "Power Menu")
        # Lanza el menú de gestión de energía de Rofi.
        # Asegúrate de que rofi-power-menu-git esté instalado y configurado.
        rofi -show p -modi p:rofi-power-menu &
        ;;
    *)
        # Si el usuario presiona Esc o una entrada no válida, no hacer nada.
        ;;
esac