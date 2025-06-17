#!/bin/bash

SHUTDOWN_SCRIPT="/home/jmro/.config/i3blocks/i3blocks-contrib/shutdown_menu/shutdown_menu"

if [ -n "$BLOCK_BUTTON" ]; then
    "$SHUTDOWN_SCRIPT"
else
    echo "APAGADO"
fi
