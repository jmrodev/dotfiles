# Dotfiles para Arch Linux + i3wm

Estos son mis dotfiles personales para un entorno de desarrollo en Arch Linux, utilizando i3wm como gestor de ventanas, zsh como shell y Neovim como editor de texto. La configuración está pensada para ser modular, fácil de mantener y personalizable.

## Características Principales

- **Gestor de Ventanas**: i3wm (configuración modular).
- **Shell**: zsh con Oh My Zsh, tema Powerlevel10k y plugins (zsh-autosuggestions, zsh-syntax-highlighting).
- **Editor de Texto**: Neovim con NvChad (v2.5), gestionado con `lazy.nvim`.
- **Terminal**: xfce4-terminal.
- **Lanzador de Aplicaciones**: Rofi con menús personalizados.
- **Instalación Automatizada**: Script para instalar todo el software necesario en Arch Linux, Void Linux y sistemas basados en Debian.
- **Gestión de Dotfiles**: Se utiliza un alias de git (`dotfiles`) para gestionar este repositorio como un "bare repository".

## Instalación

1.  **Clonar el repositorio**:
    ```bash
    git clone --bare https://github.com/tu_usuario/tu_repositorio.git $HOME/.dotfiles
    ```

2.  **Definir el alias `dotfiles`**:
    Añade la siguiente línea a tu `.bashrc` o `.zshrc`:
    ```bash
    alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
    ```
    Recarga tu shell o abre una nueva.

3.  **Hacer checkout del contenido**:
    ```bash
    dotfiles checkout
    ```
    Si recibes un error sobre archivos existentes, muévelos o elimínalos. Por ejemplo: `mv .bashrc .bashrc.bak`.

4.  **Ejecutar el script de instalación**:
    El script detectará tu sistema operativo e instalará todo el software y las dependencias necesarias.
    ```bash
    ~/.local/bin/install_software.sh
    ```

## Post-Instalación

1.  **Configurar el prompt de Powerlevel10k**:
    Al abrir zsh por primera vez, ejecuta `p10k configure` para configurar el prompt a tu gusto.

2.  **Reiniciar la sesión**:
    Cierra sesión y vuelve a iniciarla para que todos los cambios, especialmente la shell por defecto y la configuración de i3, se apliquen correctamente.

## Uso de los Dotfiles

Para gestionar los dotfiles, utiliza el alias `dotfiles` que creaste. Funciona como un alias de `git`.

-   `dotfiles status`: Ver el estado de tus archivos de configuración.
-   `dotfiles add .config/i3/config`: Añadir un archivo modificado.
-   `dotfiles commit -m "Nuevo cambio en i3"`: Hacer commit de los cambios.
-   `dotfiles push`: Subir los cambios a tu repositorio remoto.

## Atajos de Teclado (Keybindings)

La configuración de los atajos de teclado de i3 se encuentra en el directorio `~/.config/i3/conf.d/`. Los archivos principales son:
-   `20-keybindings-base.conf`
-   `20-keybindings.conf`
-   `25-keybindings-rofi.conf`
-   `30-keybindings-apps.conf`

## Software Incluido

El script `install_software.sh` instala una gran cantidad de paquetes, incluyendo:

-   **Herramientas de desarrollo**: `git`, `neovim`, `rust`, `go`, `pnpm`, `pyenv`, `docker`.
-   **Utilidades del sistema**: `fzf`, `eza`, `dunst`, `picom`, `nitrogen`.
-   **Aplicaciones**: `google-chrome`, `flameshot`, `ranger`, `pcmanfm`.
-   **Fuentes**: Nerd Fonts (MesloLGS NF) para Powerlevel10k.

Para una lista completa, revisa el script `~/.local/bin/install_software.sh`.