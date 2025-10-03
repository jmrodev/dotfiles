#!/bin/bash

# ==============================================================================
# Script Desinstalador y Limpiador de PHP en Arch Linux
#
# Este script ofrece dos opciones:
# 1. Desinstalar PHP y PHP-FPM, eliminando sus archivos de configuración.
# 2. Restaurar el archivo de configuración de Apache (httpd.conf) a su estado
#    original, antes de las modificaciones de PHP-FPM.
# ==============================================================================

# --- Funciones Comunes ---

# Función para registrar mensajes con colores
log() {
    local type="$1"
    local message="$2"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    case "$type" in
        "INFO")    echo -e "[\e[34mINFO\e[0m] $timestamp $message" ;;
        "SUCCESS") echo -e "[\e[32mSUCCESS\e[0m] $timestamp $message" ;;
        "ERROR")   echo -e "[\e[31mERROR\e[0m] $timestamp $message" ;;
        "WARN")    echo -e "[\e[33mWARN\e[0m] $timestamp $message" ;;
        *)         echo -e "[\e[37mDEBUG\e[0m] $timestamp $message" ;;
    esac
}

# Verificar privilegios de root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log "ERROR" "Este script debe ser ejecutado como root."
        exit 1
    fi
}

# --- Lógica del Desinstalador de PHP-FPM ---

uninstall_php_fpm() {
    log "INFO" "--- Iniciando desinstalación de PHP y PHP-FPM ---"
    
    # 1. Detener el servicio de PHP-FPM
    log "INFO" "Deteniendo el servicio php-fpm..."
    systemctl stop php-fpm

    # 2. Desinstalar paquetes de PHP
    log "INFO" "Desinstalando paquetes 'php' y 'php-fpm'..."
    if pacman -Rns --noconfirm php php-fpm; then
        log "SUCCESS" "Paquetes de PHP desinstalados exitosamente."
    else
        log "WARN" "Fallo al desinstalar los paquetes de PHP. Puede que ya no estén instalados."
    fi

    # Desinstalar php-apcu si está instalado
    if pacman -Q php-apcu &>/dev/null; then
        log "INFO" "Desinstalando php-apcu..."
        if pacman -Rns --noconfirm php-apcu; then
            log "SUCCESS" "Paquete 'php-apcu' desinstalado exitosamente."
        else
            log "WARN" "Fallo al desinstalar el paquete 'php-apcu'."
        fi
    fi

    # 3. Eliminar archivos y directorios de configuración
    log "INFO" "Eliminando archivos de configuración de PHP..."
    rm -rf /etc/php
    rm -f /usr/lib/php/modules/php.ini

    # Eliminar configuración de Apache para PHP-FPM
    log "INFO" "Eliminando configuración de Apache para PHP-FPM..."
    rm -f /etc/httpd/conf/extra/php-fpm.conf
    sed -i '/Include conf\/extra\/php-fpm.conf/d' /etc/httpd/conf/httpd.conf

    log "SUCCESS" "Archivos de configuración de PHP eliminados."

    # 4. Eliminar página de prueba si existe
    local DOCROOT=$(grep "^DocumentRoot" "/etc/httpd/conf/httpd.conf" | awk -F'"' '{print $2}')
    if [[ -f "$DOCROOT/info.php" ]]; then
        rm -f "$DOCROOT/info.php"
        log "SUCCESS" "Página de prueba 'info.php' eliminada."
    fi

    # 5. Verificación final
    if ! systemctl status php-fpm &>/dev/null; then
        log "SUCCESS" "El servicio php-fpm no está activo. Desinstalación completa."
    else
        log "WARN" "El servicio php-fpm aún podría estar activo. Se requiere limpieza manual."
    fi

    log "INFO" "--- Desinstalación de PHP finalizada ---"
}

# --- Lógica del Restaurador de Configuración de Apache ---

restore_apache_conf() {
    log "INFO" "--- Restaurando configuración de Apache ---"

    local HTTPD_CONF="/etc/httpd/conf/httpd.conf"
    local BACKUP_CONF=$(ls -t "${HTTPD_CONF}.bak.php_fpm."* 2>/dev/null | head -n 1)

    if [[ -z "$BACKUP_CONF" ]]; then
        log "WARN" "No se encontró un archivo de respaldo para la configuración de Apache. No se puede restaurar."
        return 1
    fi

    log "INFO" "Restaurando $BACKUP_CONF a $HTTPD_CONF..."
    cp "$BACKUP_CONF" "$HTTPD_CONF" || { log "ERROR" "Fallo al restaurar el archivo de configuración."; return 1; }
    log "SUCCESS" "Configuración de Apache restaurada."
    
    # Reiniciar Apache para aplicar los cambios
    log "INFO" "Reiniciando Apache para aplicar la configuración original..."
        systemctl restart httpd || { log "ERROR" "Fallo al reiniciar Apache. Por favor, revisa el log de errores."; return 1; }
    log "SUCCESS" "Apache reiniciado."

    log "INFO" "--- Restauración de Apache finalizada ---"
}

# --- Lógica Principal del Script ---

check_root

echo "=== Desinstalador de PHP y Restaurador de Apache para Arch Linux ==="
echo ""
echo "Selecciona una opción:"
echo "1) Desinstalar PHP y PHP-FPM completamente."
echo "2) Restaurar la configuración de Apache a su estado original (pre-instalación de PHP)."
read -p "Opción (1/2): " choice

case "$choice" in
    1)
        uninstall_php_fpm
        ;;
    2)
        restore_apache_conf
        ;;
    *)
        log "ERROR" "Opción inválida. Saliendo."
        exit 1
        ;;
esac
