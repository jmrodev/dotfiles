#!/usr/bin/env bash
set -u

SWAY_THEME_CONF="$HOME/.config/sway/definitions.d/theme.conf"
KITTY_DIR="$HOME/.config/kitty"
CURRENT_THEME_LINK="$KITTY_DIR/current-theme.conf"

THEME_MODE="dark"

if [ -f "$SWAY_THEME_CONF" ]; then
    if grep -q "prefer-light" "$SWAY_THEME_CONF"; then
        THEME_MODE="light"
    elif grep -q "prefer-dark" "$SWAY_THEME_CONF"; then
        THEME_MODE="dark"
    fi
fi

TARGET_THEME_CONF="$KITTY_DIR/theme.${THEME_MODE}.conf"

if [ -f "$TARGET_THEME_CONF" ]; then
    CURRENT_TARGET="$(readlink -f "$CURRENT_THEME_LINK" 2>/dev/null || true)"
    if [ "$CURRENT_TARGET" != "$TARGET_THEME_CONF" ]; then
        ln -sf "$TARGET_THEME_CONF" "$CURRENT_THEME_LINK"
        pkill -SIGUSR1 kitty 2>/dev/null || true
    fi
fi
