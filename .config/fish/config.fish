# ==========================================
# Configuración Core de Fish
# ==========================================

# Variables de entorno y PATH
fish_add_path $HOME/.opencode/bin
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.npm-global/bin
fish_add_path $HOME/go/bin

# Android SDK
set -gx ANDROID_HOME $HOME/Android/Sdk
fish_add_path $ANDROID_HOME/emulator
fish_add_path $ANDROID_HOME/platform-tools
set -gx _JAVA_AWT_WM_NONREPARENTING 1

# OpenCode Config
set -gx OPENCODE_EXPERIMENTAL true

# ==========================================
# Aliases y Herramientas Modernas
# ==========================================
alias ls 'eza --icons=always --color=always --group-directories-first'
alias ll 'eza -alF --icons=always --color=always --group-directories-first --header --git'
alias tree 'eza --tree --icons=always'
alias cat 'bat --style=plain'
alias man 'batman'

# Server and PBX helpers are standalone scripts in ~/.local/bin (server-on, server-off, pbx-on, pbx-off)

# Alias de Dotfiles Bare Repo
alias dotfiles '/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# ==========================================
# Inicializaciones Automáticas
# ==========================================
if command -v zoxide >/dev/null 2>&1
    zoxide init fish | source
    alias cd z
end

function jupyter -d "Inicia JupyterLab en ~/Notebooks"
    mkdir -p ~/Notebooks
    jupyter-lab ~/Notebooks
end

if command -v starship >/dev/null 2>&1
    starship init fish | source
end

if command -v fzf >/dev/null 2>&1
    fzf --fish | source
end

# ==========================================
# Tmux Autostart y Greeting (Banner 2 Col)
# ==========================================
if status is-interactive
    if test -z "$TMUX"
        exec tmux new-session -A -s main
    end
end

function fish_greeting
    # Solo mostrar en el panel inicial al abrir la terminal (ventana 0, panel 0)
    if test -n "$TMUX"
        set -l pane_info (tmux display-message -p '#{window_index}:#{pane_index}' 2>/dev/null)
        if test "$pane_info" != "0:0"
            return
        end
        cheatsheet
    end
end

function cheatsheet -d "Muestra el resumen de atajos y servicios"
    echo ""
    echo -e "  \033[1;38;5;111m🌐 ENLACES & DASHBOARDS\033[0m \033[38;5;244m(Ctrl+Sh+Clic | Shift+Clic en Tmux | Ctrl+Sh+E modo teclado)\033[0m"
    echo -e "    \033[38;5;114mDashboard Inicio\033[0m     https://inicio.mcscheerle.duckdns.org"
    echo -e "    \033[38;5;114mMonitor Red\033[0m          https://red.mcscheerle.duckdns.org"
    echo -e "    \033[38;5;114mGitea Server\033[0m         https://git.mcscheerle.duckdns.org"
    echo -e "    \033[38;5;114mVaultwarden\033[0m          https://pass.mcscheerle.duckdns.org"
    echo -e "    \033[38;5;114mImmich Fotos\033[0m         https://fotos.mcscheerle.duckdns.org"
    echo -e "    \033[38;5;114mFilebrowser\033[0m          https://archivos.mcscheerle.duckdns.org"
    echo -e "    \033[38;5;114mLinkwarden\033[0m           https://links.mcscheerle.duckdns.org"
    echo -e "    \033[38;5;114mNetdata Monitor\033[0m      https://monitor.mcscheerle.duckdns.org"
    echo -e "    \033[38;5;114mCine / Stremio\033[0m       https://cine.mcscheerle.duckdns.org"
    echo -e "    \033[38;5;114mCIMA Salud\033[0m           https://cimasalud.duckdns.org"
    echo -e "    \033[38;5;114mOpenWrt Web/WOL\033[0m      http://192.168.50.1:8088/cgi-bin/server?key=jmro-wake-2026"
    echo -e "    \033[38;5;114mOpenWrt WOL WAN\033[0m      http://jmro.duckdns.org:8088/cgi-bin/server?key=jmro-wake-2026"
    echo -e "    \033[38;5;114mHomarr Local\033[0m         http://192.168.50.10"
    echo -e "    \033[38;5;114mGitHub Perfil\033[0m        https://github.com/jmrodev"
    echo -e "    \033[38;5;114mWeb TandilLabs\033[0m       https://jmrodev.github.io/tandillabs"
    echo ""
    echo -e "  \033[1;38;5;111m📡 TOPOLOGÍA LOCAL & CONEXIONES SSH\033[0m"
    echo -e "    \033[38;5;114mssh openwrt\033[0m          Router OpenWrt Local (192.168.50.1:22)"
    echo -e "    \033[38;5;114mssh openwrt-wan\033[0m      Router OpenWrt WAN (jmro.duckdns.org:22222)"
    echo -e "    \033[38;5;114mssh jmro-debian\033[0m      Servidor Media Local (192.168.50.10)"
    echo -e "    \033[38;5;114mssh cima-rpi\033[0m         Raspberry Pi CIMA (cimasalud.duckdns.org:2223)"
    echo -e "    \033[38;5;114mssh cima-notebook\033[0m    Notebook CIMA Prod (cimasalud.duckdns.org:2222)"
    echo -e "    \033[38;5;114mssh toshiba\033[0m          Toshiba Manjaro (Tailscale 100.114.212.5)"
    echo -e "    \033[38;5;114mssh xp-open\033[0m          Windows XP / POS (192.168.50.32:2222)"
    echo ""
    echo -e "  \033[1;38;5;111m🖥️  SISTEMA & SERVICIOS\033[0m"
    echo -e "    \033[38;5;114mbtop\033[0m                 Monitor CPU, RAM y red"
    echo -e "    \033[38;5;114mduf\033[0m / \033[38;5;114mncdu\033[0m          Uso y análisis de disco"
    echo -e "    \033[38;5;114mclean\033[0m                Limpiar cachés y paquetes huérfanos"
    echo -e "    \033[38;5;114mserver-on\033[0m / \033[38;5;114moff\033[0m      WOL / Apagar servidor (192.168.50.10)"
    echo -e "    \033[38;5;114mpbx-on\033[0m / \033[38;5;114moff\033[0m         Iniciar / Frenar VoIP"
    echo -e "    \033[38;5;114mdotfiles\033[0m             Git repo del sistema"
    echo -e "    \033[38;5;114mjupyter\033[0m              Lanzar JupyterLab en ~/Notebooks"
    echo -e "    \033[38;5;114mz <dir>\033[0m              Saltar con Zoxide"
    echo -e "    \033[38;5;114mscale-display\033[0m / \033[38;5;114mfont\033[0m Escala Sway / Fuentes"
    echo ""
    echo -e "  \033[1;38;5;111m⚡ SWAY / NAVEGACIÓN & VENTANAS\033[0m"
    echo -e "    \033[38;5;114mSuper + d\033[0m            Lanzador de aplicaciones"
    echo -e "    \033[38;5;114mSuper + e\033[0m            Explorador de archivos (Dolphin)"
    echo -e "    \033[38;5;114mSuper + Enter\033[0m        Terminal (Kitty)"
    echo -e "    \033[38;5;114mSuper + i\033[0m            Workspace dedicado Chrome"
    echo -e "    \033[38;5;114mSuper + 1..9\033[0m         Cambiar a Workspace 1..9"
    echo -e "    \033[38;5;114mSuper + Tab\033[0m          Alternar con el workspace anterior"
    echo -e "    \033[38;5;114mSuper + f\033[0m            Pantalla completa (Fullscreen)"
    echo -e "    \033[38;5;114mSuper + Sh + Espacio\033[0m Alternar ventana Flotante / Mosaico"
    echo -e "    \033[38;5;114mSuper + v\033[0m            Historial de portapapeles (cliphist)"
    echo -e "    \033[38;5;114mSuper + Shift + Q\033[0m    Cerrar ventana activa"
    echo ""
    echo -e "  \033[1;38;5;111m⌨️  TMUX (Prefix: Ctrl+a)\033[0m"
    echo -e "    \033[38;5;114mC-a + v\033[0m / \033[38;5;114ms\033[0m          Dividir panel (vertical / horizontal)"
    echo -e "    \033[38;5;114mC-a + h/j/k/l\033[0m        Moverse entre paneles (o Ctrl+hjkl)"
    echo -e "    \033[38;5;114mC-a + H/J/K/L\033[0m        Redimensionar tamaño de panel"
    echo -e "    \033[38;5;114mC-a + z\033[0m              Zoom / Maximizar panel actual"
    echo -e "    \033[38;5;114mC-a + c\033[0m / \033[38;5;114mx\033[0m          Crear nueva ventana / Cerrar panel"
    echo -e "    \033[38;5;114mC-a + f\033[0m              Sessionizer (selector fzf de proyectos)"
    echo ""
    echo -e "  \033[1;38;5;111m🤖 AGENTES & IA\033[0m"
    echo -e "    \033[38;5;114mSuper + o\033[0m            OpenCode CLI"
    echo -e "    \033[38;5;114mSuper + g\033[0m            Antigravity (AGY)"
    echo -e "    \033[38;5;114mSuper + c\033[0m            AGY Code"
    echo ""
end
