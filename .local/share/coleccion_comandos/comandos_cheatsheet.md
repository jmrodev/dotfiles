# 🛠️ AI Command Idioms & CLI Cheat Sheet
> Patrones idiomáticos, defensivos y automatizables aprendidos de sesiones de agentes y pair programming en terminal.

---

## 📑 Índice
1. [Patrones Fundamentales de Shell](#1-patrones-fundamentales-de-shell)
2. [SSH y Operaciones Remotas No Interactivas](#2-ssh-y-operaciones-remotas-no-interactivas)
3. [Docker y Contenedores](#3-docker-y-contenedores)
4. [Git y GitHub CLI (`gh`)](#4-git-y-github-cli-gh)
5. [Búsqueda, Extracción y Pipelines (grep, find, sed, awk)](#5-búsqueda-extracción-y-pipelines-grep-find-sed-awk)
6. [Redes, Puertos y Diagnóstico](#6-redes-puertos-y-diagnóstico)
7. [Wayland, Sway, Audio (Pipewire) y GUI](#7-wayland-sway-audio-pipewire-y-gui)
8. [Systemd, Procesos y Salud del Sistema](#8-systemd-procesos-y-salud-del-sistema)
9. [Paquetes Arch Linux (`pacman` / `yay`)](#9-paquetes-arch-linux-pacman--yay)
10. [Multimedia, Audio y Video (`ffmpeg`)](#10-multimedia-audio-y-video-ffmpeg)
11. [Android Debug Bridge (`adb`)](#11-android-debug-bridge-adb)
12. [Bluetooth (`bluetoothctl`)](#12-bluetooth-bluetoothctl)
13. [Impresión y Servidor CUPS (`lpstat` / `lpadmin`)](#13-impresión-y-servidor-cups-lpstat--lpadmin)
14. [Multiplexores de Terminal (`tmux`)](#14-multiplexores-de-terminal-tmux)
15. [Almacenamiento en Nube (`rclone`)](#15-almacenamiento-en-nube-rclone)
16. [Ecosistema JavaScript & Node (`npm` / `pnpm` / `npx`)](#16-ecosistema-javascript--node-npm--pnpm--npx)
17. [AWS CLI & Perfiles Cloud](#17-aws-cli--perfiles-cloud)

---

## 1. Patrones Fundamentales de Shell

La IA prioriza comandos **idempotentes**, **sin paginación** (`PAGER=cat`) y **tolerantes a fallos**:

```bash
# Ejecución tolerante (no rompe el pipeline si no existe o falla)
cmd 2>/dev/null || true

# Redirigir errores al flujo estándar y filtrar
cmd 2>&1 | grep -iE "error|warning|fail"

# Validación de existencia de binarios antes de ejecutar
which <binario> >/dev/null 2>&1 && echo "✅ Instalado" || echo "❌ Falta"

# Fallback visual de credenciales (Zenity -> Kdialog)
zenity --password --title="Sudo" 2>/dev/null | sudo -S <cmd> || kdialog --password "Sudo:" 2>/dev/null | sudo -S <cmd>

# Copia limpia al portapapeles en Wayland (evita saltos de línea y trailing spaces)
echo -n "texto o snippet" | wl-copy
```

---

## 2. SSH y Operaciones Remotas No Interactivas

Para scripts o agentes, SSH **nunca** debe quedarse colgado pidiendo confirmación de host o password:

```bash
# Conexión remota desatendida con timeout estricto y sin prompt de host key
ssh -o BatchMode=yes -o ConnectTimeout=5 -o StrictHostKeyChecking=no user@<host> "<comando>"

# Forzar algoritmos antiguos de llave pública (ej. routers OpenWrt / dropbear)
ssh -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedKeyTypes=+ssh-rsa -i ~/.ssh/id_rsa user@<host> "<comando>"

# Enviar comandos multilínea o scripts remotos limpios vía stdin
ssh user@<host> "bash -s" << 'EOF'
echo "=== Diagnóstico de Nodo ==="
uname -a
df -h /
EOF

# Port forwarding temporal en background sin shell interactivo (-f -N)
ssh -f -N -L 8080:127.0.0.1:80 user@<host>
```

---

## 3. Docker y Contenedores

Formateo tabular preciso y comandos dentro de contenedores usando variables del entorno:

```bash
# Formateo limpio de contenedores activos sin desbordar terminal
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"

# Ejecutar comando en contenedor usando variables del propio contenedor
docker exec <container-name> sh -c 'echo "DB: $DB_NAME" && psql -U "$DB_USER" -d "$DB_NAME" -c "\dt"'

# Copiar archivos hacia/desde contenedor sin montar volúmenes
docker cp <container-name>:/path/en/container/config.json ./config.local.json

# Limpieza no interactiva de imágenes huérfanas y contenedores parados
docker container prune -f && docker image prune -f

# Inspeccionar solo la IP de un contenedor específico
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' <container-name>

# Seguir logs limitando las líneas iniciales
docker logs --tail 50 -f <container-name>
```

---

## 4. Git y GitHub CLI (`gh`)

Workflows directos de ramas, diffs y Pull Requests sin necesidad de navegador:

```bash
# Ver historial condensado entre dos ramas
git log origin/main..HEAD --oneline --no-merges

# Listar qué archivos cambiaron respecto a main
git diff --stat origin/main...HEAD

# Buscar en qué commit o archivo se introdujo una cadena específica (Pickaxe)
git log -S "nombre_de_variable" --oneline

# Listar ramas locales que ya fueron fusionadas y eliminadas del remoto
git fetch --prune && git branch -vv | grep ': gone]' | awk '{print $1}'

# GitHub CLI: Crear PR completo desde terminal
gh pr create --base main --head <mi-rama> --title "feat: descripcion" --body "Detalle del cambio"

# GitHub CLI: Monitorear CI/CD y auto-mergear al aprobar
gh pr checks <numero_pr> --watch && gh pr merge <numero_pr> --merge --auto

# GitHub CLI: Extraer campos específicos en formato JSON parseable
gh pr list --state open --json number,title,author --jq '.[] | "\(.number) - \(.title) (@\(.author.login))"'
```

---

## 5. Búsqueda, Extracción y Pipelines (grep, find, sed, awk)

Extracción precisa de patrones sin recurrir a scripts complejos:

```bash
# Grep recursivo excluyendo directorios pesados
grep -rn --exclude-dir={node_modules,.git,dist,.venv} "PATRON" .

# Buscar archivos modificados en los últimos N minutos
find . -maxdepth 3 -type f -mmin -60 ! -path "*/.*"

# Reemplazo de cadenas in-place seguro en archivos
sed -i 's/127\.0\.0\.1:8080/0\.0\.0\.0:80/g' <archivo>

# Extraer solo la columna N filtrando por regex (ej. puertos a la escucha)
ss -tulnp | awk '/LISTEN/ {print $5}' | awk -F: '{print $NF}' | sort -n | uniq

# Ejecutar una acción sobre cada archivo encontrado sin problemas de espacios
find /path/ -name "*.log" -type f -print0 | xargs -0 rm -f

# Truncar visualización de comandos extensos sin romper el buffer
cmd | head -n 40
```

---

## 6. Redes, Puertos y Diagnóstico

```bash
# Ver qué proceso tiene tomado un puerto puntual (sin netstat obsoleto)
ss -tulpn | grep :<puerto>

# Test de conectividad a socket TCP con timeout nativo de Bash (sin nc ni telnet)
timeout 2 bash -c "</dev/tcp/<host>/<puerto>" && echo "Puerto abierto" || echo "Puerto cerrado"

# Test rápido de headers HTTP con redirecciones seguidas
curl -sIL -o /dev/null -w "%{http_code} (%{time_total}s) -> %{url_effective}\n" https://<dominio>

# Ver IPs locales activas en la interfaz primaria
ip -br addr show | grep -E "UP|UNKNOWN"
```

---

## 7. Wayland, Sway, Audio (Pipewire) y GUI

```bash
# Sway: Recargar configuración o validar sintaxis
sway -C && swaymsg reload

# Sway: Obtener la ventana actualmente en foco (JSON)
swaymsg -t get_tree | jq '.. | select(.type?) | select(.focused==true)'

# Pipewire (wpctl): Listar sinks y fuentes de audio
wpctl status | grep -E "Sinks|Sources" -A 10

# Pipewire: Ajustar volumen de un nodo por ID o default
wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

# Capturar ventana o región seleccionada en Wayland al portapapeles
grim -g "$(slurp)" - | wl-copy --type image/png
```

---

## 8. Systemd, Procesos y Salud del Sistema

```bash
# Chequear estado de un servicio sin paginación (útil para scripts)
systemctl is-active --quiet <servicio> && echo "Activo" || echo "Inactivo"

# Ver los últimos 30 logs de un servicio específico
journalctl -u <servicio> -n 30 --no-pager

# Monitorear uso de memoria de los 10 procesos más pesados
ps aux --sort=-%mem | awk 'NR<=10 {printf "%-10s %-8s %-5s %-5s %s\n", $1, $2, $3, $4, $11}'

# Matar procesos de manera segura buscando por patrón en línea de comando
pkill -f "nombre_proceso"
```

---

## 9. Paquetes Arch Linux (`pacman` / `yay`)

```bash
# Buscar paquetes instalados localmente por nombre o descripción (-Qs)
pacman -Qs <termino>

# Averiguar a qué paquete del sistema pertenece un archivo binario o librería
pacman -Qo /usr/bin/<comando>

# Listar paquetes huérfanos (instalados como dependencias que ya nadie necesita)
pacman -Qdtq

# Limpieza segura de la caché de paquetes conservando solo las versiones activas
paccache -r 2>/dev/null || sudo pacman -Sc --noconfirm

# Instalación no interactiva desatendida vía yay
yay -S --noconfirm --needed <paquete>
```

---

## 10. Multimedia, Audio y Video (`ffmpeg`)

```bash
# Extraer audio MP3/Opus sin recodificar (stream copy ultra rápido)
ffmpeg -i video.mp4 -vn -c:a copy audio.aac

# Capturar stream HLS/M3U8 con headers personalizados y timeout de seguridad
timeout --signal=INT 60 ffmpeg -y -headers "User-Agent: Mozilla/5.0\r\nReferer: https://sitio.com/\r\n" -i "https://stream.m3u8" -c copy grabacion.mp4

# Redimensionar video a 1080p manteniendo proporción
ffmpeg -i entrada.mp4 -vf "scale=1920:-2" -c:v libx264 -crf 23 -preset fast -c:a copy salida.mp4

# Recortar video sin re-renderizar (corte exacto por timestamps)
ffmpeg -ss 00:01:30 -to 00:04:15 -i entrada.mp4 -c copy corte.mp4
```

---

## 11. Android Debug Bridge (`adb`)

```bash
# Listar dispositivos conectados con detalles de modelo y transporte
adb devices -l

# Ejecutar comandos apuntando a un dispositivo específico por número de serie
adb -s <SERIAL> shell getprop ro.product.model

# Extraer el APK instalado de una aplicación específica
adb shell pm path com.ejemplo.app | sed 's/package://' | xargs -I{} adb pull {} ./app.apk

# Reiniciar dispositivo en modo recovery o bootloader directamente
adb -s <SERIAL> reboot recovery
```

---

## 12. Bluetooth (`bluetoothctl`)

```bash
# Escaneo de dispositivos durante N segundos sin bloquear la terminal
timeout 5 bluetoothctl scan on 2>&1 || true; bluetoothctl devices

# Consultar información, batería y estado de conexión de un dispositivo por MAC
bluetoothctl info <XX:XX:XX:XX:XX:XX>

# Conectar dispositivo de audio confiado
bluetoothctl trust <MAC> && bluetoothctl connect <MAC>
```

---

## 13. Impresión y Servidor CUPS (`lpstat` / `lpadmin`)

```bash
# Ver estado de todas las impresoras configuradas y la predeterminada (-d)
lpstat -p -d

# Ver trabajos pendientes en la cola de impresión
lpstat -o

# Reanudar o reactivar una impresora pausada/bloqueada
cupsenable <nombre_impresora> && cupsaccept <nombre_impresora>

# Cancelar todos los trabajos pendientes de una cola
cancel -a <nombre_impresora>
```

---

## 14. Multiplexores de Terminal (`tmux`)

```bash
# Recargar ~/.tmux.conf al vuelo sin cerrar paneles ni sesiones activas
tmux source-file ~/.tmux.conf && echo "Config recargada"

# Crear una sesión nombrada en segundo plano si no existe (-d)
tmux has-session -t dev 2>/dev/null || tmux new-session -d -s dev

# Enviar comandos a un panel específico sin cambiar de foco
tmux send-keys -t dev:0.0 "npm run dev" C-m

# Listar todas las sesiones activas
tmux list-sessions
```

---

## 15. Almacenamiento en Nube (`rclone`)

```bash
# Listar remotos configurados (Google Drive, S3, WebDAV, etc.)
rclone listremotes

# Listar directorios remotos sin agotar cuotas de API de Google Drive
rclone lsd gdrive: --drive-pacer-min-sleep 200ms

# Sincronización unidireccional segura con simulación previa (--dry-run)
rclone sync /local/path remote:backup/ --dry-run --progress
```

---

## 16. Ecosistema JavaScript & Node (`npm` / `pnpm` / `npx`)

```bash
# Ejecutar un paquete CLI sin instalarlo globalmente
npx <paquete>@latest <argumentos>

# Auditar y listar dependencias desactualizadas a nivel raíz
pnpm outdated || npm outdated

# Inspeccionar configuración efectiva o valores de registro de npm
npm config get registry && npm config get allow-remote

# Limpieza segura de cachés locales de paquetes
pnpm store prune || npm cache clean --force
```

---

## 17. AWS CLI & Perfiles Cloud

```bash
# Configurar parámetros rápidos de perfil sin asistente interactivo
aws configure set region us-east-1 --profile <perfil>

# Login vía SSO / Identity Center desatendido
aws login --profile <perfil> 2>&1 || true

# Consultar identidad activa del perfil (verificación de credenciales válidas)
aws sts get-caller-identity --profile <perfil> --output table

# Listar buckets S3 de forma compacta
aws s3 ls --profile <perfil>
```
