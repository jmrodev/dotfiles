# Guía Completa de Reinstalación de Manjaro Sway

Fecha de respaldo: 2026-10-08
Ubicación de este respaldo: `~/backup_reinstalacion/`

---

## 1. Archivos en este Directorio

* `native_packages.txt`: Lista de 277 paquetes oficiales explícitamente instalados.
* `aur_packages.txt`: Lista de 35 paquetes instalados desde AUR con `yay`.
* `all_explicit_packages.txt`: Lista unificada de todos los paquetes explícitos.
* `all_installed_packages.txt`: Lista completa con versiones y dependencias (referencia).
* `fstab.old`: Tu archivo `/etc/fstab` original (contiene la configuración del montaje SSHFS a `ServerDebian`).
* `usr_local_bin/`: Tus scripts personalizados (`sway`, `pkexec`).
* `reinstalar_todo.sh`: Script interactivo para reinstalar todo automáticamente.

---

## 2. Mapa del Disco NVMe (`/dev/nvme0n1` - 256 GB)

1. `nvme0n1p1` (499 MB FAT32) -> Partición EFI / Arranque (¡NO FORMATEAR!).
2. `nvme0n1p2` (128 MB) -> Reservado Microsoft.
3. `nvme0n1p3` (90.6 GB NTFS) -> Windows.
4. **Espacio libre sin formato (56.8 GB)** -> Justo entre Windows y tu Linux actual.
5. **`nvme0n1p4` (88.0 GB Btrfs)** -> Contiene tu `@home` con tus datos y este respaldo.
   * *Estado actual:* 33 GB ocupados, 50 GB libres (sistema viejo y snapshots eliminados).

---

## 3. Pasos para Particionar e Instalar

### Paso 1: En GParted
1. Abre `gparted`.
2. Selecciona el espacio sin asignar de **56.8 GiB** entre Windows (`nvme0n1p3`) y `nvme0n1p4`.
3. Clic derecho > **Nueva**:
   * Tipo: Partición primaria.
   * Sistema de archivos: `btrfs` o `ext4` (según preferencia para el sistema).
   * Etiqueta: `manjaro_root`.
4. Aplica los cambios (icono de verificación verde).

### Paso 2: En el Instalador de Manjaro (Calamares)
1. Inicia el instalador y ve a la sección **Particionado**.
2. Selecciona **Particionado Manual**:
   * **`nvme0n1p1` (EFI, 499 MB):**
     * Editar > Punto de montaje: `/boot/efi`
     * **¡IMPORTANTE: NO marcar la casilla "Formatear"!**
   * **La partición nueva de 56.8 GB:**
     * Editar > Punto de montaje: `/`
     * **Marcar "Formatear"**.
   * **`nvme0n1p4` (88 GB Btrfs - Tu Home actual):**
     * Editar > Punto de montaje: `/home`
     * **¡CRUCIAL: Asegúrate de que la casilla "Formatear" esté DESMARCADA!**
3. Crea tu usuario con el mismo nombre (`jmro`).
4. Procede con la instalación.

---

## 4. Reinstalación de Paquetes (Primer Inicio)

Una vez iniciado tu nuevo Manjaro Sway:

### Opción A (Automática con script):
```bash
chmod +x ~/backup_reinstalacion/reinstalar_todo.sh
~/backup_reinstalacion/reinstalar_todo.sh
```

### Opción B (Comandos manuales):

#### 1. Paquetes oficiales:
```bash
sudo pacman -Syu --needed - < ~/backup_reinstalacion/native_packages.txt
```

#### 2. Paquetes AUR (con yay):
```bash
yay -S --needed - < ~/backup_reinstalacion/aur_packages.txt
```

#### 3. Aplicaciones Flatpak:
```bash
flatpak install flathub com.stremio.Stremio com.w1hkj.fldigi -y
```

---

## 5. Restaurar Montajes y Scripts Personalizados

### Montaje SSHFS (ServerDebian):
Revisa `~/backup_reinstalacion/fstab.old` y añade la siguiente línea a tu nuevo `/etc/fstab`:
```text
jmro@192.168.50.10:/ /home/jmro/ServerDebian fuse.sshfs noauto,x-systemd.automount,_netdev,reconnect,ConnectTimeout=3,ServerAliveCountMax=2,x-systemd.mount-timeout=3s,x-systemd.device-timeout=3s,IdentityFile=/home/jmro/.ssh/id_ed25519,UserKnownHostsFile=/home/jmro/.ssh/known_hosts,allow_other,uid=1000,gid=1000,ServerAliveInterval=15,follow_symlinks 0 0
```

### Scripts de `/usr/local/bin`:
```bash
sudo cp ~/backup_reinstalacion/usr_local_bin/* /usr/local/bin/
sudo chmod +x /usr/local/bin/*
```

---

## 6. Consejos sobre Snapshots de Btrfs y Timeshift

### ¿Cuánto ocupa un snapshot?
* **Al crearlo:** Prácticamente **0 bytes** gracias a Copy-on-Write (CoW).
* **Con el tiempo:** Solo la diferencia de archivos que se actualicen o eliminen. Un snapshot tomado antes de actualizar ocupa entre 500 MB y 2 GB.
* Si no se limpian, se acumulan meses de kernels y librerías viejas, llegando a ocupar más de 30-40 GB (lo que ocurría en el sistema viejo).

### ¿Conviene usarlos?
**Sí, absolutamente.** En Manjaro te permite arrancar desde un snapshot si un driver o actualización rompe el entorno gráfico.

### Configuración recomendada en Timeshift para tu nuevo sistema:
1. **Límite estricto de retención:** Conservar únicamente **2 o 3 snapshots como máximo**.
2. **Periodicidad:** 1 diario o solo los generados automáticamente antes de actualizar con `timeshift-autosnap-manjaro`.
3. **Desactivar snapshots automáticos de `@home`:** Timeshift debe respaldar solo el sistema (`@`), nunca los archivos personales (tus archivos ya están protegidos en tu partición o con dotfiles/git).
