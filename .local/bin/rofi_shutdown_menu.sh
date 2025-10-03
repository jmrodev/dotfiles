#!/bin/bash

options="Shutdown
Reboot
Logout"

selected_option=$(echo -e "$options" | rofi -dmenu -p "Power Menu")

case "$selected_option" in
    "Shutdown")
        systemctl poweroff
        ;;
    "Reboot")
        systemctl reboot
        ;;
    "Logout")
        i3-msg exit
        ;;
esac
