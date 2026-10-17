# 🌐 ENLACES & DASHBOARDS
- **Dashboard Inicio:** https://inicio.mcscheerle.duckdns.org
- **Monitor Red:** https://red.mcscheerle.duckdns.org
- **Gitea Server:** https://git.mcscheerle.duckdns.org
- **Vaultwarden:** https://pass.mcscheerle.duckdns.org
- **Immich Fotos:** https://fotos.mcscheerle.duckdns.org
- **Filebrowser:** https://archivos.mcscheerle.duckdns.org
- **Linkwarden:** https://links.mcscheerle.duckdns.org
- **Netdata Monitor:** https://monitor.mcscheerle.duckdns.org
- **Cine / Stremio:** https://cine.mcscheerle.duckdns.org
- **CIMA Salud:** https://cimasalud.duckdns.org
- **OpenWrt Web/WOL:** http://192.168.50.1:8088/cgi-bin/server?key=jmro-wake-2026
- **OpenWrt WOL WAN:** http://jmro.duckdns.org:8088/cgi-bin/server?key=jmro-wake-2026
- **OpenWrt LuCI WAN:** http://jmro.duckdns.org:8088/cgi-bin/luci
- **Homarr / Caddy:** http://media (o http://192.168.50.10)
- **Portainer Media:** http://media:9000
- **File Browser Media:** http://media:8082
- **qBittorrent Media:** http://media:8080
- **Sonarr / Radarr:** http://media/sonarr | http://media/radarr
- **GameVault Media:** http://media:8081
- **GitHub Perfil:** https://github.com/jmrodev
- **Web TandilLabs:** https://jmrodev.github.io/tandillabs

---

# 📡 TOPOLOGÍA LOCAL & CONEXIONES SSH
- `ssh openwrt`: Router OpenWrt Local (192.168.50.1:22)
- `ssh openwrt-wan`: Router OpenWrt WAN (jmro.duckdns.org:22222)
- `ssh jmro-debian`: Servidor Media Local (192.168.50.10)
- `ssh debian-wan`: Servidor via OpenWrt Jump (jmro.duckdns.org)
- `ssh cima-rpi`: Raspberry Pi CIMA (cimasalud.duckdns.org:2223)
- `ssh cima-notebook`: Notebook CIMA Prod (cimasalud.duckdns.org:2222)
- `ssh toshiba`: Toshiba Manjaro (Tailscale 100.114.212.5)
- `ssh xp-open`: Windows XP / POS (192.168.50.32:2222)

---

# 🖥️ SISTEMA & SERVICIOS
- `btop`: Monitor CPU, RAM y red
- `duf` / `ncdu`: Uso y análisis de disco
- `clean`: Limpiar cachés y paquetes huérfanos
- `server-on` / `server-off`: WOL / Apagar servidor (192.168.50.10)
- `pbx-on` / `pbx-off`: Iniciar / Frenar VoIP
- `ncr-print` / `ncr-editor`: Imprimir / Editor tickets térmica NCR
- `collect-cmds`: Recolectar comandos de sesiones AGY
- `capture-stream`: Capturar flujo HLS (m3u8)
- `record-screen`: Grabar área de pantalla + audio
- `dotfiles`: Git repo del sistema
- `jupyter`: Lanzar JupyterLab en ~/Notebooks
- `z <dir>`: Saltar con Zoxide
- `scale-display` / `scale-font`: Escala Sway / Fuentes
