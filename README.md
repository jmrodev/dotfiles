# Dotfiles para Arch Linux + Sway (Wayland)

Estos son mis dotfiles personales para un entorno de desarrollo moderno en Arch Linux, utilizando **Sway** como gestor de ventanas (Wayland), **foot** como terminal, **zsh** como shell y **Neovim (NvChad v2.5)** como editor de texto.

La configuración está optimizada para rendimiento, soporte de gestos (como el pegado con tres dedos a través del touchpad) y un historial de portapapeles persistente nativo de Wayland.

## Características Principales

*   **Gestor de Ventanas**: [Sway](https://swaywm.org/) (sucesor de i3wm en Wayland).
*   **Terminal**: [foot](https://codeberg.org/dnkl/foot) (emulador de terminal ultra-rápido y ligero para Wayland).
*   **Barra de Estado**: [Waybar](https://github.com/Alexays/Waybar) (altamente personalizable con CSS).
*   **Lanzador de Aplicaciones**: [Wofi](https://hg.sr.ht/~scoopta/wofi) (lanzador nativo de Wayland compatible con menús drun/dmenu).
*   **Shell**: `zsh` con Oh My Zsh, tema Powerlevel10k y plugins de auto-sugerencias y coloreado de sintaxis.
*   **Editor de Texto**: Neovim con la base de **NvChad (v2.5)**, optimizado para desarrollo en PHP, React, JS/TS, CSS/Tailwind, Bash y MySQL.
*   **Portapapeles**: Configuración avanzada con `wl-clipboard`, `wl-clip-persist` (preserva datos al cerrar apps) y `cliphist` (historial accesible con `Mod + Shift + V`).
*   **Gestos de Touchpad**: Pegado rápido mediante pulsación con tres dedos configurado en el touchpad (`tap_button_map lrm`).
*   **Instalación Automatizada**: Script robusto e independiente del hardware para levantar el sistema completo.
*   **Gestión**: Repositorio Git gestionado como un "bare repository" mediante el alias `dotfiles`.

## Instalación

1.  **Clonar el repositorio**:
    ```bash
    git clone --bare https://github.com/jmrodev/dotfiles.git $HOME/.dotfiles
    ```

2.  **Definir el alias `dotfiles`**:
    Añade la siguiente línea a tu archivo de configuración de shell (por ejemplo, `.zshrc` o `.bashrc`):
    ```bash
    alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
    ```
    Reinicia tu terminal o haz `source ~/.zshrc`.

3.  **Hacer checkout del contenido de la rama `sway`**:
    ```bash
    dotfiles checkout sway
    ```
    Si hay conflictos con archivos existentes (como un `.zshrc` por defecto), elimínalos o muévelos antes de reintentar.

4.  **Ejecutar el script de instalación**:
    ```bash
    ~/.local/bin/install_software.sh
    ```
    El script detectará tu sistema operativo (Arch/Void/Debian) e instalará todas las herramientas esenciales, incluyendo Sway, foot, Waybar, wofi y las fuentes necesarias.

## Post-Instalación

1.  **Configurar variables locales**:
    Crea un archivo local `~/.zshrc.local` para guardar tus claves de API o configuraciones específicas de esa máquina que no quieras subir a Git:
    ```bash
    export GEMINI_API_KEY="tu_clave_aqui"
    ```

2.  **Iniciar sesión en Sway**:
    Reinicia tu equipo o cierra la sesión actual. Selecciona la sesión de Sway desde tu gestor de acceso para entrar al entorno gráfico.

## Atajos de Teclado Clave (Sway)

*   `Mod + Enter`: Abrir terminal `foot`.
*   `Mod + d`: Lanzar menú de aplicaciones `Wofi`.
*   `Mod + Shift + q`: Cerrar ventana enfocada.
*   `Mod + Shift + e`: Menú de salida (reiniciar, apagar, cerrar sesión).
*   `Mod + Shift + V`: Abrir historial del portapapeles (`cliphist`).
*   `Mod + Ctrl + n`: Abrir Neovim rápidamente.
*   `Mod + Ctrl + r`: Abrir gestor de archivos `ranger`.

## Estructura de Configuración de Sway

Los archivos de configuración de Sway se organizan de forma modular bajo `~/.config/sway/config.d/`:
*   `00-variables.conf`: Definición de aplicaciones por defecto, comandos de brillo/volumen y variables de tema.
*   `10-manjaro-ui.conf`: Estilos de bordes, fuentes y decoración de ventanas.
*   `20-base.conf`: Reglas básicas de Sway y distribución de pantalla.
*   `30-apps.conf`: Mapeo de atajos para aplicaciones comunes (Nvim, Chrome, Ranger, Dolphin).
*   `40-hardware.conf`: Configuración del touchpad (gesto de 3 dedos, tap-to-click).
*   `45-clipboard.conf`: Daemon de sincronización de portapapeles de Wayland.
*   `99-modes.conf`: Modos de redimensionamiento y control de energía.
