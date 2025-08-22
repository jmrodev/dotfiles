# Mis Dotfiles (jmrodev)

![preview](https://user-images.githubusercontent.com/583231/154322197-c86f47c2-42a7-48ac-822c-dc4d332b928d.png)

*Tu imagen de previsualización podría ir aquí. ¡Sube una captura de pantalla a una issue de GitHub y pega el enlace!*

Este repositorio contiene mi configuración personal para un entorno de desarrollo productivo en **Arch Linux** y **Void Linux**, usando **i3**, **Zsh**, **Rofi**, **Neovim (NvChad)** y más. Todo se gestiona a través de un [repositorio bare de Git](https://www.atlassian.com/git/tutorials/dotfiles), lo que permite versionar y desplegar la configuración fácilmente en cualquier máquina nueva.

El script de instalación detectará automáticamente tu distribución y instalará los paquetes correspondientes.

---

## Guía de Instalación Rápida

### Para Arch Linux

Sigue estos pasos en una instalación limpia de Arch Linux.

**1. Requisitos Previos**

Solo necesitas `git` para empezar.

```bash
sudo pacman -S --noconfirm git
```

### Para Void Linux

Sigue estos pasos en una instalación limpia de Void Linux.

**1. Requisitos Previos**

Necesitas `git` y `xtools` (para compilar si es necesario).

```bash
sudo xbps-install -S --yes git xtools
```

### 2. Clonar el Repositorio

Clona este repositorio como un "bare repository" en tu directorio `$HOME`.

```bash
git clone --bare https://github.com/jmrodev/dotfiles.git $HOME/.dotfiles
```

### 3. Desplegar los Dotfiles

Define un alias temporal para interactuar con el repositorio y luego despliega los archivos de configuración.

```bash
# Define el alias en tu sesión actual
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Intenta desplegar los archivos
dotfiles checkout
```

**Si recibes un error** sobre archivos existentes que serían sobreescritos (lo cual es muy probable), ejecuta el siguiente bloque de comandos. Este moverá los archivos conflictivos a una carpeta de respaldo y volverá a intentar el despliegue.

```bash
mkdir -p ~/.dotfiles-backup && \
dotfiles checkout 2>&1 | grep -E "\s+\." | awk {'print $1'} | xargs -I{} mv {} ~/.dotfiles-backup/{} && \
dotfiles checkout
```

Finalmente, configura el repositorio para que no muestre todos los archivos no rastreados de tu home:

```bash
dotfiles config --local status.showUntrackedFiles no
```

### 4. Instalar todo el Software

Ahora que tus dotfiles (incluyendo tus scripts personalizados) están en su sitio, haz que el script de instalación sea ejecutable y córrelo.

```bash
# Dar permisos de ejecución
chmod +x ~/.local/bin/install_software.sh

# Ejecutar el instalador
~/.local/bin/install_software.sh
```

El script detectará tu sistema operativo e instalará el software correspondiente.
- **En Arch Linux:** Instalará paquetes de los repositorios oficiales y del AUR (usando `yay`).
- **En Void Linux:** Instalará paquetes desde los repositorios oficiales usando `xbps`.

**Nota para usuarios de Void Linux:**
- Algunos paquetes del AUR no están disponibles en los repositorios de Void (ej. `rofi-bluetooth-git`, `google-chrome`). Estos han sido omitidos.
- La gestión de servicios se realiza con `runit` (`sv` command) en lugar de `systemd`. Se han añadido alias de Zsh (`start`, `stop`, `restart`, etc.) que usan `sv` automáticamente.

---

## ¡Listo!

Reinicia tu sesión o tu máquina para que todos los servicios y configuraciones (i3, Zsh, etc.) se carguen correctamente. Tu nuevo entorno debería estar listo y ser idéntico al original.

## Mantenimiento

Para añadir un nuevo archivo a tus dotfiles, simplemente usa los alias que ya tienes configurados en tu `.zshrc`:

```bash
# Añadir un nuevo archivo
da ~/.config/nueva-app/config.conf

# Hacer commit
dc "feat: Añadir configuración para nueva-app"

# Subir los cambios
dp
```
