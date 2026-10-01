function limpieza --description "Limpia paquetes huérfanos, cachés y archivos basura del sistema"
    set -l before_kb (df -k / | awk 'NR==2 {print $3}')
    
    echo "=> 🧹 Iniciando limpieza profunda del sistema..."

    # 1. Huérfanos de pacman
    echo "=> 📦 Buscando paquetes huérfanos de Arch..."
    set orphans (pacman -Qdtq 2>/dev/null)
    if test -n "$orphans"
        sudo pacman -Rns (string split \n $orphans) --noconfirm
    else
        echo "   No hay paquetes huérfanos."
    end

    # 2. Journald logs
    echo "=> 📜 Limpiando logs del sistema (dejando últimos 7 días)..."
    sudo journalctl --vacuum-time=7d

    # 3. Flatpak
    if type -q flatpak
        echo "=> 📦 Limpiando flatpaks sin uso..."
        flatpak uninstall --unused -y
    end

    # 4. Docker
    if type -q docker
        echo "=> 🐳 Limpiando caché de compilación de Docker..."
        docker builder prune -a -f
    end

    # 5. Node/NPM/PNPM
    if type -q npm
        echo "=> 📦 Limpiando caché de NPM..."
        npm cache clean --force >/dev/null 2>&1
    end
    if type -q pnpm
        echo "=> 📦 Limpiando caché de PNPM..."
        pnpm store prune >/dev/null 2>&1
    end

    # 6. Navegadores y Slack
    echo "=> 🗑️ Vaciando cachés de navegadores (Chrome/Brave) y Slack..."
    rm -rf ~/.cache/google-chrome/Default/Cache 2>/dev/null
    rm -rf ~/.cache/BraveSoftware/Brave-Browser/Default/Cache 2>/dev/null
    rm -rf ~/.config/Slack/Cache 2>/dev/null
    rm -rf ~/.config/Slack/Service\ Worker/CacheStorage 2>/dev/null
    rm -rf ~/.config/Slack/Code\ Cache 2>/dev/null

    # 6.5. Stremio
    echo "=> 🎬 Vaciando caché de Stremio..."
    rm -rf ~/.var/app/com.stremio.Stremio/.stremio-server/stremio-cache/* 2>/dev/null
    
    # 7. Cálculo
    set -l after_kb (df -k / | awk 'NR==2 {print $3}')
    set -l saved_kb (math "$before_kb - $after_kb")
    
    if test $saved_kb -lt 0
        set saved_kb 0
    end

    set -l saved_mb (math "$saved_kb / 1024")
    
    echo ""
    echo "=> ✨ ¡Limpieza completada con éxito!"
    
    if test $saved_mb -ge 1024
        set -l saved_gb (math "$saved_mb / 1024")
        printf "=> 📉 Espacio recuperado en total: %.2f GB\n" $saved_gb
    else if test $saved_mb -gt 0
        printf "=> 📉 Espacio recuperado en total: %.0f MB\n" $saved_mb
    else
        echo "=> 📉 Espacio recuperado: 0 MB (¡El sistema ya estaba impecable!)"
    end

    # Reporte de estado actual del disco
    set -l final_free_kb (df -k / | awk 'NR==2 {print $4}')
    set -l final_used_gb (math "$after_kb / 1024 / 1024")
    set -l final_free_gb (math "$final_free_kb / 1024 / 1024")
    
    echo "----------------------------------------"
    printf "=> 💾 Espacio Usado Actual : %.2f GB\n" $final_used_gb
    printf "=> 💿 Espacio Libre Actual : %.2f GB\n" $final_free_gb
end
