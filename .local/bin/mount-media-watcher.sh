#!/usr/bin/env bash
set -euo pipefail

HOST="100.106.211.71"
PORT="22"
USER="jmro"
MOUNT_POINT="/home/jmro/Mounts/ServerDebian"

mkdir -p "$MOUNT_POINT"

# Verifica con timeout rapido (1s) si el puerto SSH responde por Tailscale
if nc -z -w 1 "$HOST" "$PORT" 2>/dev/null; then
    # Si esta alcanzable y NO esta montado, montar
    if ! mountpoint -q "$MOUNT_POINT"; then
        sshfs "${USER}@${HOST}:/" "$MOUNT_POINT" \
            -o reconnect,ConnectTimeout=3,ServerAliveInterval=15,ServerAliveCountMax=2,follow_symlinks,IdentityFile=/home/jmro/.ssh/id_ed25519
    fi
else
    # Si el servidor no responde pero sigue montado (se apago o desconecto), desmontar perezosamente para no congelar Dolphin
    if mountpoint -q "$MOUNT_POINT"; then
        fusermount -u -z "$MOUNT_POINT" || true
    fi
fi
