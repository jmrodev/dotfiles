#!/usr/bin/env bash
set -uo pipefail

HOSTS=("192.168.50.10" "100.106.211.71")
PORT="22"
USER="jmro"
MOUNT_POINT="/home/jmro/Mounts/ServerDebian"

mkdir -p "$MOUNT_POINT" 2>/dev/null || true

# Verificar montaje via /proc/mounts (nunca cuelga en estado D como mountpoint/stat)
is_mounted() {
    grep -qs " ${MOUNT_POINT} " /proc/mounts
}

ACTIVE_HOST=""
for h in "${HOSTS[@]}"; do
    if timeout 2 bash -c "</dev/tcp/$h/$PORT" 2>/dev/null; then
        ACTIVE_HOST="$h"
        break
    fi
done

if [ -n "$ACTIVE_HOST" ]; then
    if ! is_mounted; then
        sshfs "${USER}@${ACTIVE_HOST}:/" "$MOUNT_POINT" \
            -o reconnect,ConnectTimeout=3,ServerAliveInterval=15,ServerAliveCountMax=2,follow_symlinks,IdentityFile=/home/jmro/.ssh/id_ed25519
    else
        # Si ya está montado pero quedó roto (stale), verificar con timeout y limpiar
        if ! timeout 2 stat -t "$MOUNT_POINT" >/dev/null 2>&1; then
            fusermount -u -z "$MOUNT_POINT" 2>/dev/null || true
        fi
    fi
else
    # Sin conexión al servidor: si sigue montado, lazy-unmount para no bloquear suspensión ni el sistema
    if is_mounted; then
        fusermount -u -z "$MOUNT_POINT" 2>/dev/null || true
    fi
fi
