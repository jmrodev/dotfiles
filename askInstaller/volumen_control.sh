#!/bin/bash

# Script para controlar volumen y micrófono y mostrar OSD/Notificación
# Necesita: pactl (para PulseAudio), volnoti (para OSD de volumen),
# notify-send (para notificaciones de micrófono)

# Configura el sink (salida de audio) y source (entrada de audio) por defecto
# usando los identificadores especiales de PulseAudio.
# Si usas PipeWire, @DEFAULT_SINK@ y @DEFAULT_SOURCE@ deberían seguir funcionando
# con pactl, ya que PipeWire proporciona compatibilidad.
DEFAULT_SINK="@DEFAULT_SINK@"
DEFAULT_SOURCE="@DEFAULT_SOURCE@"

# Usa un ID de notificación persistente para actualizar la misma notificación
# si decides usar notify-send para volumen en lugar de volnoti.
# NOTIFICATION_ID="9910"

# --- Lógica para cambiar volumen/mute ---

# El primer argumento pasado al script determina la acción
case "$1" in
    up)
        # Aumenta el volumen del sink predeterminado en un 10%
        pactl set-sink-volume "$DEFAULT_SINK" +10%
        ACTION="volume_changed" # Marca la acción para la parte de notificación
        ;;
    down)
        # Disminuye el volumen del sink predeterminado en un 10%
        pactl set-sink-volume "$DEFAULT_SINK" -10%
        ACTION="volume_changed" # Marca la acción para la parte de notificación
        ;;
    mute)
        # Alterna el estado de silencio del sink predeterminado
        pactl set-sink-mute "$DEFAULT_SINK" toggle
        ACTION="mute_toggled" # Marca la acción para la parte de notificación
        ;;
    micmute)
        # Alterna el estado de silencio del source predeterminado (micrófono)
        pactl set-source-mute "$DEFAULT_SOURCE" toggle
        ACTION="micmute_toggled" # Marca la acción para la parte de notificación
        ;;
    *)
        # Si se llama con un argumento desconocido, muestra uso y sale
        echo "Uso: $0 {up|down|mute|micmute}"
        exit 1
        ;;
esac

# Opcional: Si usas i3status para mostrar el volumen, puedes forzar una actualización aquí.
# Si la notificación es suficiente, no necesitas esta línea.
# killall -SIGUSR1 i3status

# --- Lógica para mostrar la notificación/OSD después de la acción ---

# Solo procedemos si una acción reconocida fue ejecutada
if [ -n "$ACTION" ]; then

    # Obtener el estado actual del sink (volumen y mute)
    # Necesitas ajustar el `awk '{print $X}'` según la salida exacta de `pactl list sinks`
    # en tu sistema. Ejecuta `pactl list sinks` en una terminal para verificar.
    volume_info=$(pactl list sinks | grep -A 15 "Name: $DEFAULT_SINK")
    # Intenta obtener el porcentaje numérico. Ejemplo: "Volume: 0: 70% 1: 70%" -> 70
    # Esta extracción asume que el porcentaje es el 5to campo después de 'Volume:' en la primera línea relevante.
    volume_percent=$(echo "$volume_info" | grep 'Volume:' | head -n 1 | awk '{print $5}' | sed 's/%//') # Extrae el 5to campo y remueve el '%'
    # Intenta obtener el estado de mute. Ejemplo: "Mute: no" -> no
    # Esta extracción asume que el estado de mute es el 2do campo después de 'Mute:' en la primera línea relevante.
    is_muted=$(echo "$volume_info" | grep 'Mute:' | head -n 1 | awk '{print $2}')

    # Llamar a volnoti-show o notify-send para el volumen/sink
    if [ "$ACTION" == "volume_changed" ] || [ "$ACTION" == "mute_toggled" ]; then
        if [ "$is_muted" == "yes" ]; then
            # Si está silenciado, muestra 0 a volnoti o usa notify-send
            # Consulta la documentación de volnoti-show sobre cómo maneja el mute.
            # volnoti-show 0 # Puede mostrar el ícono de mute o 0 volumen
            # O usar notify-send para indicar mute:
            notify-send -t 2000 -p -u low "notification-audio-volume-muted" "Silenciado" # -u low = prioridad baja
        elif [ -n "$volume_percent" ]; then # Asegúrate de que se haya extraído un número
            # Si no está silenciado, muestra el porcentaje a volnoti
            volnoti-show "$volume_percent"
        fi
    fi

    # Lógica específica para la notificación de micrófono (usando notify-send)
    # Volnoti no suele tener soporte directo para notificaciones de micrófono.
    if [ "$ACTION" == "micmute_toggled" ]; then
         mic_info=$(pactl list sources | grep -A 15 "Name: $DEFAULT_SOURCE")
         mic_is_muted=$(echo "$mic_info" | grep 'Mute:' | head -n 1 | awk '{print $2}') # Ajustar si es necesario

         ICON=""
         TEXT=""
         if [ "$mic_is_muted" == "yes" ]; then
             ICON="microphone-sensitivity-muted" # Icono estándar para micrófono silenciado
             TEXT="Micrófono Silenciado"
         else
             ICON="microphone-sensitivity-high" # Icono estándar para micrófono activo
             TEXT="Micrófono Activo"
         fi
         # Enviar la notificación de micrófono. Usar un ID diferente si quieres que coexista con notis de volumen.
         # notify-send -t 2000 -p -r "$MIC_NOTIFICATION_ID" "$ICON" "$TEXT" # Si usas ID persistente
         notify-send -t 2000 -p -u low "$ICON" "$TEXT" # Sin ID persistente
    fi

fi # Fin del if [ -n "$ACTION" ]

exit 0
