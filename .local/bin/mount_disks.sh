#!/bin/bash

# Define tu emulador de terminal preferido. Esto se usa si hay un error
# y el script necesita mostrar la salida del comando en la terminal.
TERMINAL="xfce4-terminal" # <-- ¡IMPORTANTE! Cambia esto a tu terminal (ej. kitty, xfce4-terminal, gnome-terminal)

# Función para enviar notificaciones de escritorio.
# Requiere un demonio de notificación como 'dunst' instalado.
notify() {
    notify-send -t 3000 "Rofi Disk Utility" "$1"
}

# --- Menú Principal de Rofi: Montar o Desmontar ---
OPTIONS="Mount\nUnmount"
CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -p "Select action:")

case "$CHOICE" in
    "Mount")
        # Obtener una lista de dispositivos de disco (que no son 'loop' ni 'nvme')
        # que actualmente NO están montados (MOUNTPOINT está vacío).
        # Extraemos el nombre del dispositivo, tamaño y modelo para mostrar en Rofi.
        DEVICES=$(lsblk -o NAME,SIZE,MODEL,MOUNTPOINT,FSTYPE,UUID | grep 'disk' | grep -v 'loop' | grep -v 'nvme' | awk '{ if ($4 == "") print "/dev/" $1 " (" $2 " " $3 ")" }')

        if [ -z "$DEVICES" ]; then
            notify "No unmounted devices found."
            exit 0
        fi

        # Mostrar el menú de dispositivos no montados en Rofi y obtener la selección.
        DEVICE_TO_MOUNT_RAW=$(echo -e "$DEVICES" | rofi -dmenu -p "Select device to mount:")

        if [ -n "$DEVICE_TO_MOUNT_RAW" ]; then
            # Extraer solo la ruta del dispositivo principal (ej. /dev/sdb) de la selección de Rofi.
            DEV_PATH=$(echo "$DEVICE_TO_MOUNT_RAW" | awk '{print $1}')
            # Buscar la primera partición de ese dispositivo.
            # 'lsblk -lnp' lista en formato parseable, NR==2 asume que la segunda línea es la primera partición.
            PARTITION=$(lsblk -lnp "$DEV_PATH" | awk 'NR==2 {print $1}')

            if [ -n "$PARTITION" ]; then
                notify "Attempting to mount $PARTITION..."
                # Intentar montar la partición usando udisksctl.
                # 'udisksctl' es ideal porque maneja los puntos de montaje y permisos automáticamente.
                udisksctl mount -b "$PARTITION"
                if [ $? -eq 0 ]; then # Verificar si el comando anterior fue exitoso
                    # Si se montó, obtener el punto de montaje y notificar.
                    MOUNT_POINT=$(udisksctl info -b "$PARTITION" | grep "MountPoints" | awk '{print $2}')
                    notify "Mounted $PARTITION at $MOUNT_POINT"
                else
                    # Si falla el montaje, notificar y abrir una terminal para mostrar el error.
                    notify "Failed to mount $PARTITION. Check terminal for errors."
                    "$TERMINAL" -e bash -c "udisksctl mount -b $PARTITION; read -p 'Press Enter to close...'"
                fi
            else
                notify "No mountable partition found on $DEV_PATH."
            fi
        fi
        ;;

    "Unmount")
        # Obtener una lista de dispositivos actualmente montados que son gestionados por udisks2.
        # Esto incluye dispositivos USB, externos, etc., que Rofi montaría automáticamente.
        MOUNTED_DEVICES=$(udisksctl status | grep "device" | grep -v "read-only" | awk '{print $NF}')

        if [ -z "$MOUNTED_DEVICES" ]; then
            notify "No udisks2-managed devices currently mounted."
            exit 0
        fi

        # Mostrar el menú de dispositivos montados en Rofi y obtener la selección.
        DEVICE_TO_UNMOUNT=$(echo -e "$MOUNTED_DEVICES" | rofi -dmenu -p "Select device to unmount:")

        if [ -n "$DEVICE_TO_UNMOUNT" ]; then
            notify "Attempting to unmount $DEVICE_TO_UNMOUNT..."
            # Intentar desmontar el dispositivo.
            udisksctl unmount -b "$DEVICE_TO_UNMOUNT"
            if [ $? -eq 0 ]; then # Verificar si el comando anterior fue exitoso
                notify "Unmounted $DEVICE_TO_UNMOUNT"
            else
                # Si falla el desmontaje, notificar y abrir una terminal para mostrar el error.
                notify "Failed to unmount $DEVICE_TO_UNMOUNT. Check terminal for errors."
                "$TERMINAL" -e bash -c "udisksctl unmount -b $DEVICE_TO_UNMOUNT; read -p 'Press Enter to close...'"
            fi
        fi
        ;;
esac