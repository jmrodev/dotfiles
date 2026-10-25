# Guía Completa de Reinstalación de Manjaro Sway

Fecha de respaldo: 2026-10-25
Ubicación de este respaldo: `~/backup_reinstalacion/` (enlazado a `~/.dotfiles/backup_reinstalacion/`)

---

## 1. Archivos en este Directorio

* `native_packages.txt`: Lista de 267 paquetes oficiales explícitamente instalados (sin defaults).
* `aur_packages.txt`: Lista de 34 paquetes instalados desde AUR con `yay`.
* `all_explicit_packages.txt`: Lista unificada de 289 paquetes explícitos totales.
* `all_installed_packages.txt`: Lista completa con versiones y dependencias (referencia).
* `fstab.old`: Tu archivo `/etc/fstab` original (referencia de montajes).
* `usr_local_bin/`: Tus scripts personalizados (`sway`, `pkexec`).
* `reinstalar_todo.sh`: Script interactivo para reinstalar todo automáticamente.

---

## 2. Mapa del Disco NVMe (`/dev/nvme0n1` - 256 GB)

1. `nvme0n1p1` (499 MB FAT32) -> Partición EFI / Arranque (Punto de montaje: `/boot/efi` - **¡NO FORMATEAR!**).
2. `nvme0n1p2` (128 MB) -> Reservado Microsoft.
3. `nvme0n1p3` (90.6 GB NTFS) -> Windows.
4. `nvme0n1p5` (2.4 GB NTFS) -> Partición de Recuperación de Windows.
5. **`nvme0n1p6` (56.8 GB Btrfs)** -> **Sistema Raíz (`/`)**.
   * Aquí se instala el nuevo sistema operativo (**Marcar "Formatear"**).
6. **`nvme0n1p4` (88.0 GB Btrfs)** -> **Tu Home (`/home`)**.
   * Contiene tu usuario `jmro`, datos, proyectos y dotfiles.
   * **¡CRUCIAL: Asegúrate de que la casilla "Formatear" esté DESMARCADA!**

---

## 3. Pasos en el Instalador de Manjaro (Calamares)

1. Inicia el instalador desde el Live USB y ve a la sección **Particionado**.
2. Selecciona **Particionado Manual**:
   * **`nvme0n1p1` (EFI, 499 MB):**
     * Editar > Punto de montaje: `/boot/efi`
     * **¡IMPORTANTE: NO marcar la casilla "Formatear"!**
   * **`nvme0n1p6` (56.8 GB Btrfs):**
     * Editar > Punto de montaje: `/`
     * **Marcar "Formatear"** (Btrfs o Ext4 según prefieras; Btrfs recomendado con compresión).
   * **`nvme0n1p4` (88 GB Btrfs - Tu Home actual):**
     * Editar > Punto de montaje: `/home`
     * **¡CRUCIAL: DESMARCAR "Formatear"!**
3. En la pantalla de usuarios:
   * Nombre de usuario exacto: `jmro`
   * Misma contraseña (o nueva si prefieres).
4. Procede con la instalación.

---

## 4. Reinstalación de Paquetes (Primer Inicio)

Una vez iniciado tu nuevo Manjaro Sway:

### Opción A (Automática con script):
```bash
chmod +x ~/backup_reinstalacion/reinstalar_todo.sh
~/backup_reinstalacion/reinstalar_todo.sh
```

El script restaurará interactivamente:
1. Paquetes oficiales (`pacman`) excluyendo los que ya vienen por defecto.
2. Paquetes de usuario desde **AUR** (`yay`).
3. Flatpaks requeridos (Stremio, FLDIGI).
4. Scripts en `/usr/local/bin` (`sway`, `pkexec`).
5. Configuraciones del sistema (`/etc/docker/daemon.json`, reglas udev NCR).
6. Grupos de usuario (`docker`, `kvm`, `input`, `video`, etc.) y servicios systemd.
7. Entorno `uv` (Python fast tooling).

---

## 5. Restaurar Montajes y Scripts Personalizados

### Montaje SSHFS (ServerDebian):
Si usas el montaje automático por fstab, añade esta línea a tu nuevo `/etc/fstab`:
```text
jmro@192.168.50.10:/ /home/jmro/Mounts/ServerDebian fuse.sshfs noauto,x-systemd.automount,_netdev,reconnect,ConnectTimeout=3,ServerAliveCountMax=2,x-systemd.mount-timeout=3s,x-systemd.device-timeout=3s,IdentityFile=/home/jmro/.ssh/id_ed25519,UserKnownHostsFile=/home/jmro/.ssh/known_hosts,allow_other,uid=1000,gid=1000,ServerAliveInterval=15,follow_symlinks 0 0
```
*(Alternativamente, tu servicio systemd de usuario `mount-media.service` ya está trackeado en dotfiles).*

### Scripts de `/usr/local/bin`:
El script `reinstalar_todo.sh` se encarga de esto, pero si lo haces manual:
```bash
sudo cp ~/backup_reinstalacion/usr_local_bin/* /usr/local/bin/
sudo chmod +x /usr/local/bin/*
```

---

## 6. Consejos sobre Snapshots de Btrfs y Timeshift

### Configuración recomendada en Timeshift:
1. **Límite de retención:** Conservar únicamente **2 o 3 snapshots como máximo**.
2. **Periodicidad:** Solo automáticos antes de actualizar (`timeshift-autosnap-manjaro`).
3. **Desactivar snapshots de `@home`:** Timeshift debe respaldar solo `@` (la raíz `/`), nunca `@home`.
