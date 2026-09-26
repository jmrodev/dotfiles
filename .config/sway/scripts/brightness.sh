#!/bin/sh
# Custom wrapper to prevent brightness from going over 94%
# This works around a known AMDGPU panel bug where >94% PWM wraps around and turns off the screen.

current_abs=$(brightnessctl get)
max_safe=61603 # 94% of 65535
factor=3
brightness_step=$((65535 * factor / 100))

case $1'' in
'') ;;
'down')
    if [ "$current_abs" -le "$brightness_step" ]; then
        brightnessctl --quiet set 1
    else
        brightnessctl --quiet set "${brightness_step}-"
    fi
    ;;
'up')
    if [ "$current_abs" -lt "$((max_safe - brightness_step))" ]; then
        brightnessctl --quiet set "${brightness_step}+"
    else
        brightnessctl --quiet set "$max_safe"
    fi
    ;;
esac

echo "$(brightnessctl get) * 100 / 65535" | bc
