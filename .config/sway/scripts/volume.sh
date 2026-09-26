#!/bin/bash
STEP="5%"
LIMIT="1.80"

current=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}')
curr_int=$(echo "$current * 100" | bc | cut -d. -f1)

case $1 in
    up)
        if [ "$curr_int" -lt 100 ]; then
            wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ "$STEP+"
            new_vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}')
            new_int=$(echo "$new_vol * 100" | bc | cut -d. -f1)
            if [ "$new_int" -eq 100 ]; then
                date +%s%3N > /tmp/vol_pause_time
            fi
        elif [ "$curr_int" -eq 100 ]; then
            NOW=$(date +%s%3N)
            LAST=$(cat /tmp/vol_pause_time 2>/dev/null || echo 0)
            if [ $((NOW - LAST)) -gt 800 ]; then
                wpctl set-volume -l $LIMIT @DEFAULT_AUDIO_SINK@ "$STEP+"
            else
                echo $NOW > /tmp/vol_pause_time
            fi
        else
            wpctl set-volume -l $LIMIT @DEFAULT_AUDIO_SINK@ "$STEP+"
        fi
        ;;
    down)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ "$STEP-"
        ;;
esac
