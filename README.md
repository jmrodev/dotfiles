# Mis Dotfiles

Este repositorio contiene mis archivos de configuración personal (dotfiles) para un entorno de desarrollo y trabajo en Linux. Los gestiono usando un repositorio Git bare, lo que permite mantener mi directorio `$HOME` limpio y versionar solo los archivos que me interesan.

---

## Estructura del Repositorio

Este es un repositorio **bare** de Git. Esto significa que el directorio `.git` tradicional (donde se guarda el historial del repositorio) no está en `$HOME`, sino que este mismo directorio (`$HOME/.dotfiles/`) actúa como el repositorio Git.

Los archivos de configuración que gestiono se encuentran en mi directorio `$HOME`, y son rastreados por este repositorio.

---

## Archivos Gestionados (Ejemplos)

Aquí hay una lista de algunos de los archivos y directorios que gestiono con este repositorio:

* `.bashrc`: Configuración de Bash.
* `.gitconfig`: Configuración global de Git.
* `.zshrc`: Configuración de Zsh (si lo usas).
* `.vimrc`: Configuración de Vim.
* `.config/nvim/init.vim`: Configuración de NeoVim (si lo usas).
* `.config/i3/config`: Configuración del gestor de ventanas i3 (si lo usas).
* `.tmux.conf`: Configuración de Tmux (si lo usas).
* `bin/`: (Si tienes scripts personales en `~/bin`)
* *(Añade aquí otros archivos o directorios importantes que gestiones)*

---

## Cómo Clonar e Instalar (Primera Vez en una Nueva Máquina)

Sigue estos pasos para clonar este repositorio y configurar tus dotfiles en una nueva máquina. ¡**Haz una copia de seguridad** de tus dotfiles existentes antes de comenzar!

1.  **Clonar el repositorio bare:**
    ```bash
    git clone --bare [https://github.com/tu_usuario/dotfiles.git](https://github.com/tu_usuario/dotfiles.git) $HOME/.dotfiles
    ```
    *(Reemplaza `https://github.com/tu_usuario/dotfiles.git` con la URL real de tu repositorio.)*

2.  **Configurar el alias `dotfiles`:**
    Añade la siguiente línea a tu `~/.bashrc` (o `~/.zshrc`):
    ```bash
    alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
    ```
    Luego, recarga tu shell:
    ```bash
    source ~/.bashrc  # o source ~/.zshrc
    ```

3.  **Hacer checkout de los archivos:**
    Este paso intentará colocar los archivos del repositorio en tu `$HOME`. Es posible que genere advertencias si ya tienes archivos con el mismo nombre.
    ```bash
    dotfiles checkout
    ```
    Si recibes advertencias como `error: The following untracked working tree files would be overwritten by checkout:`, puedes listar los archivos que entran en conflicto y decidir si los quieres sobrescribir o mover manualmente:
    ```bash
    dotfiles checkout 2>&1 | egrep "\s(overwrite|warning):"
    ```
    Si estás seguro de sobrescribir tus archivos existentes con los del repositorio:
    ```bash
    dotfiles checkout -f
    ```
    **¡ADVERTENCIA!** El comando `-f` (force) sobrescribirá tus archivos locales sin preguntar. ¡Úsalo con precaución!

4.  **Configurar archivos sin rastrear (opcional):**
    Si tienes archivos locales que no están rastreados por Git pero quieres empezar a gestionarlos, puedes añadirlos:
    ```bash
    dotfiles add .nombre_de_archivo
    dotfiles commit -m "Añadir nuevo dotfile"
    ```

---

## Uso Diario (Después de la Instalación)

Una vez configurado el alias, puedes usar `dotfiles` como si fuera el comando `git` normal para gestionar tus dotfiles:

* **Ver el estado de tus dotfiles:**
    ```bash
    dotfiles status
    ```

* **Añadir cambios:**
    ```bash
    dotfiles add .bashrc
    ```

* **Guardar cambios:**
    ```bash
    dotfiles commit -m "Mensaje de commit"
    ```

* **Sincronizar con el repositorio remoto (GitHub, GitLab, etc.):**
    ```bash
    dotfiles pull  # Para obtener las últimas actualizaciones
    dotfiles push  # Para subir tus cambios
    ```

---

## Contacto

Si tienes preguntas o sugerencias, no dudes en abrir un "issue" en este repositorio.
