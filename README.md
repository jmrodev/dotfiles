# 🚀 Dotfiles — Manjaro Sway + Kitty + Herdr

Configuración personal para entorno de desarrollo y productividad en Linux Wayland (Manjaro Sway).

---

## 🏗️ Stack del Entorno

- **Window Manager:** Sway (Wayland)
- **Barra de estado:** Waybar (personalizada con Gammastep, DND, volumen, batería y reloj)
- **Terminal Oficial:** [Kitty](https://sw.kovidgoyal.net/kitty/) (Fuente: *JetBrainsMono Nerd Font* 14px, fondo 90% opacidad, sincronización de tema claro/oscuro)
- **Shell:** Fish Shell (con Zoxide, eza, bat, secretos desacoplados)
- **Multiplexer y Orquestador de Agentes:** [Herdr](https://github.com/jmrodev/herdr) (`Ctrl+b` como prefijo base)
- **Agentes e IA:** Antigravity (AGY), OpenCode CLI, AGY Code
- **Editor:** Neovim (LazyVim)

---

## 📦 Estructura del Repositorio

Este repositorio se gestiona mediante un **Git Bare Repository** ubicado en `~/.dotfiles`:

```text
~/.dotfiles/                 <- Directorio git bare
├── .config/
│   ├── sway/                <- Configuración del compositor Sway
│   ├── waybar/              <- Barra Waybar limpia y reactiva
│   ├── kitty/               <- Configuración de terminal y temas
│   ├── herdr/               <- Configuración y sesiones de Herdr
│   ├── fish/                <- Funciones, aliases y configuración de shell
│   ├── cheatsheets/         <- Manuales interactivos personales (`cheatsheet`)
│   ├── environment.d/       <- Variables de entorno persistentes para la sesión
│   └── ...
├── .local/bin/              <- Scripts y utilidades propias (gammastep, homestate, etc.)
└── backup_reinstalacion/    <- Scripts de auto-instalación y listas de paquetes
```

---

## ⚡ Atajos de Teclado Principales

### Sistema & Ventanas (Sway)
| Atajo | Acción |
| :--- | :--- |
| `Super + Enter` | Terminal oficial (**Kitty + Herdr**) |
| `Super + d` | Lanzador de aplicaciones |
| `Super + e` | Explorador de archivos (Dolphin) |
| `Super + v` | Historial de portapapeles (`cliphist`) |
| `Super + Shift + Q` | Cerrar ventana activa |
| `Super + f` | Pantalla completa (Fullscreen) |
| `Super + Shift + Espacio` | Alternar ventana flotante / mosaico |
| `Super + 1..9` | Cambiar a espacio de trabajo 1..9 |

### Espacios de Trabajo para Agentes e IA
| Atajo | Herramienta |
| :--- | :--- |
| `Super + o` | OpenCode CLI |
| `Super + g` | Antigravity (AGY) |
| `Super + c` | AGY Code |

### Multiplexer (Herdr)
- **Prefijo base:** `Ctrl + b`
- Usar `cheatsheet herdr` en la terminal para ver el manual interactivo completo.

---

## 🛠️ Herramientas Propias del Sistema

- **`cheatsheet`**: Sistema interactivo con buscador `fzf` para consultar manuales y atajos al vuelo.
- **`homestate diff`**: Compara el estado del sistema con el snapshot para auditar candidatos a dotfiles.
- **`homestate snapshot`**: Guarda la foto base del estado de dotfiles en SQLite.
- **`sync-package-backup`**: Compara tus paquetes contra los defaults de fábrica de Manjaro Sway y actualiza las listas de instalación sin duplicados.
- **`gammastep-control`**: Controlador con soporte para clics, rueda del mouse y menú Rofi para temperatura y brillo.
- **`shmooz`**: Lupa y anotador interactivo para Wayland.

---

## 💻 Instalación en una Máquina Nueva

### 1. Clonar el repositorio Bare de Dotfiles
```bash
git clone --bare https://github.com/jmrodev/dotfiles.git $HOME/.dotfiles

# Definir función temporal para operar el bare repo
function dotfiles {
   /usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME "$@"
}

# Desplegar archivos en tu $HOME
dotfiles checkout
# Si hay conflictos con archivos default creados por el sistema:
# dotfiles checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} rm {}
# dotfiles checkout

dotfiles config --local status.showUntrackedFiles no
```

### 2. Auto-instalación de paquetes y dependencias
El directorio `backup_reinstalacion` contiene las listas generadas dinámicamente:
```bash
cd ~/.dotfiles/backup_reinstalacion
./reinstalar_todo.sh
```

El script restaurará interactivamente:
1. Paquetes oficiales (`pacman`) excluyendo los que ya vienen por defecto.
2. Paquetes de usuario desde **AUR** (`yay`).
3. Flatpaks requeridos.
4. Servicios de systemd (Docker, Bluetooth, Tailscale, etc.) y grupos de usuario.
