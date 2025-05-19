#!/bin/bash

# Instalador para la herramienta 'ask'
# Instala en ~/bin/ask_gemini/, crea un lanzador en ~/bin/ask,
# y ayuda a configurar el PATH si es necesario.

# --- Configuración ---
USER_BIN_DIR="$HOME/bin"
APP_INSTALL_SUBDIR="ask_gemini"
APP_INSTALL_DIR="${USER_BIN_DIR}/${APP_INSTALL_SUBDIR}"

LAUNCHER_NAME="ask"
PYTHON_HELPER_NAME="ask_gemini.py"
GENERAL_CONTEXT_BASENAME=".ask_context.general"
API_KEY_FILENAME=".ask_api_key"

# --- Funciones ---
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "\nError: El comando requerido '$1' no se encuentra." >&2
        echo "Por favor, instálalo antes de continuar." >&2
        return 1
    fi
    return 0
}

check_python_package() {
    if python3 -c "import $1" &> /dev/null; then
        return 0
    else
        echo -e "\nError: La librería '$1' de Python no se encuentra." >&2
        echo "Puedes instalarla con: pip3 install --user $1 (o sudo pip3 install $1)" >&2
        return 1
    fi
}

ensure_dir_in_path() {
    local dir_to_check="$1"
    local path_addition_string="export PATH=\"\$HOME/bin:\$PATH\"" # Usar $HOME/bin explícitamente
    local shell_rc_file=""
    local shell_name=$(basename "$SHELL")

    if [[ ":$PATH:" != *":${dir_to_check}:"* ]]; then
        echo ""
        echo "Advertencia: El directorio '$dir_to_check' no parece estar en tu PATH actual."
        
        if [ "$shell_name" = "bash" ]; then
            shell_rc_file="$HOME/.bashrc"
        elif [ "$shell_name" = "zsh" ]; then
            shell_rc_file="$HOME/.zshrc"
        else
            echo "No se pudo detectar tu shell principal para añadir '$dir_to_check' al PATH automáticamente."
            echo "Por favor, añade la siguiente línea a tu archivo de configuración del shell (ej. ~/.bashrc, ~/.zshrc, ~/.profile):"
            echo "  $path_addition_string"
            return 1
        fi

        read -r -p "¿Quieres que intente añadir '$dir_to_check' a tu '$shell_rc_file'? (s/N): " confirm_add_path
        if [[ "$confirm_add_path" =~ ^[sS]$ ]]; then
            if [ -f "$shell_rc_file" ]; then
                if grep -Fxq "$path_addition_string" "$shell_rc_file"; then
                    echo "'$path_addition_string' ya está en '$shell_rc_file'."
                else
                    echo "Añadiendo '$path_addition_string' a '$shell_rc_file'..."
                    echo "" >> "$shell_rc_file" # Asegurar nueva línea antes
                    echo "$path_addition_string" >> "$shell_rc_file"
                    echo "¡Hecho! Por favor, recarga tu shell o abre una nueva terminal para que los cambios surtan efecto."
                    echo "Puedes hacerlo con: source $shell_rc_file"
                fi
            else
                echo "El archivo '$shell_rc_file' no existe. Creándolo y añadiendo la línea del PATH..."
                echo "$path_addition_string" >> "$shell_rc_file"
                echo "¡Hecho! Por favor, recarga tu shell o abre una nueva terminal para que los cambios surtan efecto."
            fi
        else
            echo "No se añadió '$dir_to_check' al PATH automáticamente."
            echo "Por favor, añade la siguiente línea a tu archivo de configuración del shell:"
            echo "  $path_addition_string"
        fi
    else
        echo "El directorio '$dir_to_check' ya está en tu PATH."
    fi
}


# --- Comprobaciones Previas ---
echo "Instalador para la herramienta 'ask'"
echo "------------------------------------"

# No se necesita root si instalamos en $HOME/bin

echo -n "Comprobando dependencias del sistema... "
missing_deps=0
for cmd in python3 pip3 glow curl xdg-open; do 
    if ! check_command "$cmd"; then missing_deps=1; fi
done
if ! check_python_package "requests"; then missing_deps=1; fi

if [ "$missing_deps" -eq 1 ]; then
    echo "Instalación abortada debido a dependencias faltantes." >&2
    echo "Ejemplo para Manjaro/Arch: sudo pacman -S python-pip glow curl xdg-utils" >&2
    exit 1
fi
echo "OK."

# --- Crear directorios de instalación ---
echo ""
echo "--- Preparando Directorios de Instalación ---"
echo "Asegurando que '$USER_BIN_DIR' exista..."
if [ ! -d "$USER_BIN_DIR" ]; then
    echo "El directorio '$USER_BIN_DIR' no existe. Creándolo..."
    mkdir -p "$USER_BIN_DIR"
    if [ $? -ne 0 ]; then 
        echo "Error al crear el directorio '$USER_BIN_DIR'. Abortando." >&2; exit 1; 
    else
        echo "Directorio '$USER_BIN_DIR' creado."
    fi
else
    echo "Directorio '$USER_BIN_DIR' ya existe."
fi

echo "Asegurando que '$APP_INSTALL_DIR' exista..."
mkdir -p "$APP_INSTALL_DIR"
if [ $? -ne 0 ]; then echo "Error al crear/acceder a '$APP_INSTALL_DIR'. Abortando." >&2; exit 1; fi
echo "Directorios listos."


# --- Configuración de GEMINI_API_KEY ---
# ... (Sección de API Key igual que en la respuesta anterior) ...
echo ""
echo "--- Configuración de la Clave API de Gemini ---"
API_KEY_FILE_PATH="${APP_INSTALL_DIR}/${API_KEY_FILENAME}" 
CURRENT_API_KEY_IN_FILE=""
API_KEY_CONFIGURED_IN_FILE=false 

if [ -f "$API_KEY_FILE_PATH" ]; then
    echo "Ya existe un archivo de clave API en '$API_KEY_FILE_PATH'."
    read -r -p "¿Quieres sobrescribir la clave API guardada? (s/N): " choice_overwrite_key
    if [[ ! "$choice_overwrite_key" =~ ^[sS]$ ]]; then
        echo "Configuración de la clave API omitida. Se usará la clave existente en el archivo (si es válida)."
        API_KEY_CONFIGURED_IN_FILE=true
    fi
fi

NEW_API_KEY_TO_SAVE=""
if [ "$API_KEY_CONFIGURED_IN_FILE" = false ]; then 
    echo "Necesitarás una Clave API de Google Gemini."
    echo "Puedes obtener una desde: https://aistudio.google.com/app/apikey"
    read -r -p "¿Quieres que intente abrir esta URL en tu navegador? (s/N): " open_browser
    if [[ "$open_browser" =~ ^[sS]$ ]]; then
        xdg-open "https://aistudio.google.com/app/apikey" &> /dev/null || \
        echo "No se pudo abrir el navegador. Por favor, abre la URL manualmente."
    fi
    echo ""
    echo "Una vez que tengas tu clave API, por favor pégala aquí y presiona Enter:"
    read -r -s -p "GEMINI_API_KEY: " pasted_api_key
    echo "" 
    
    if [ -z "$pasted_api_key" ]; then
        echo "No se ingresó ninguna clave API. No se guardará ninguna clave nueva."
    elif [[ "$pasted_api_key" != AIza* ]] || [ ${#pasted_api_key} -lt 30 ]; then
        echo "Advertencia: La clave API ingresada no parece tener el formato esperado."
        read -r -p "¿Estás seguro de que es correcta y quieres guardarla? (s/N): " confirm_key_format
        if [[ "$confirm_key_format" =~ ^[sS]$ ]]; then
            NEW_API_KEY_TO_SAVE="$pasted_api_key"
        else
            echo "Guardado de la clave API cancelado."
        fi
    else
        NEW_API_KEY_TO_SAVE="$pasted_api_key"
    fi

    if [ -n "$NEW_API_KEY_TO_SAVE" ]; then
        echo "Guardando la clave API en '$API_KEY_FILE_PATH'..."
        echo "${NEW_API_KEY_TO_SAVE}" > "$API_KEY_FILE_PATH" 
        if [ $? -eq 0 ]; then
            chmod 600 "$API_KEY_FILE_PATH"
            echo "Clave API guardada exitosamente en '$API_KEY_FILE_PATH'."
        else
            echo "Error: No se pudo guardar la clave API en '$API_KEY_FILE_PATH'." >&2
            NEW_API_KEY_TO_SAVE="" 
        fi
    fi
fi


# --- Localización de Archivos del Script de Origen ---
SOURCE_DIR=$(dirname "$(readlink -f "$0")")
ASK_WRAPPER_SOURCE="${SOURCE_DIR}/${LAUNCHER_NAME}"
PYTHON_HELPER_SOURCE="${SOURCE_DIR}/${PYTHON_HELPER_NAME}"
GENERAL_CONTEXT_SOURCE_EXAMPLE="${SOURCE_DIR}/${GENERAL_CONTEXT_BASENAME}.example"
MANPAGE_SOURCE="${SOURCE_DIR}/${LAUNCHER_NAME}.1"


if [ ! -f "$ASK_WRAPPER_SOURCE" ]; then
    echo "Error: No se encuentra el script lanzador '$LAUNCHER_NAME' en '$SOURCE_DIR'." >&2; exit 1;
fi
if [ ! -f "$PYTHON_HELPER_SOURCE" ]; then
    echo "Error: No se encuentra el script de Python '$PYTHON_HELPER_NAME' en '$SOURCE_DIR'." >&2; exit 1;
fi

# --- Proceso de Instalación ---
echo ""
echo "--- Iniciando Instalación de los Archivos ---"

echo "Instalando '$PYTHON_HELPER_NAME' en '$APP_INSTALL_DIR'..."
cp "$PYTHON_HELPER_SOURCE" "${APP_INSTALL_DIR}/${PYTHON_HELPER_NAME}"
if [ $? -ne 0 ]; then echo "Error al copiar '$PYTHON_HELPER_NAME'. Abortando." >&2; exit 1; fi
chmod u+x "${APP_INSTALL_DIR}/${PYTHON_HELPER_NAME}" 

if [ -f "$GENERAL_CONTEXT_SOURCE_EXAMPLE" ]; then
    if [ ! -f "${APP_INSTALL_DIR}/${GENERAL_CONTEXT_BASENAME}" ] || \
       ( read -r -p "El archivo de contexto general '${APP_INSTALL_DIR}/${GENERAL_CONTEXT_BASENAME}' ya existe. ¿Sobrescribir con el ejemplo? (s/N): " confirm_overwrite_general_ctx && \
         [[ "$confirm_overwrite_general_ctx" =~ ^[sS]$ ]] ); then
        echo "Instalando archivo de contexto general de EJEMPLO en '${APP_INSTALL_DIR}/${GENERAL_CONTEXT_BASENAME}'..."
        cp "$GENERAL_CONTEXT_SOURCE_EXAMPLE" "${APP_INSTALL_DIR}/${GENERAL_CONTEXT_BASENAME}"
        chmod 600 "${APP_INSTALL_DIR}/${GENERAL_CONTEXT_BASENAME}"
    else
        echo "El archivo de contexto general '${APP_INSTALL_DIR}/${GENERAL_CONTEXT_BASENAME}' no se modificó."
    fi
elif [ ! -f "${APP_INSTALL_DIR}/${GENERAL_CONTEXT_BASENAME}" ]; then
    echo "Creando un archivo de contexto general vacío en '${APP_INSTALL_DIR}/${GENERAL_CONTEXT_BASENAME}'..."
    touch "${APP_INSTALL_DIR}/${GENERAL_CONTEXT_BASENAME}"
    chmod 600 "${APP_INSTALL_DIR}/${GENERAL_CONTEXT_BASENAME}"
fi

echo "Instalando lanzador '$LAUNCHER_NAME' en '$USER_BIN_DIR'..."
cp "$ASK_WRAPPER_SOURCE" "${USER_BIN_DIR}/${LAUNCHER_NAME}"
if [ $? -ne 0 ]; then echo "Error al copiar '$LAUNCHER_NAME'. Abortando." >&2; exit 1; fi
chmod +x "${USER_BIN_DIR}/${LAUNCHER_NAME}"
if [ $? -ne 0 ]; then echo "Error al dar permisos a '$LAUNCHER_NAME'. Abortando." >&2; exit 1; fi


MANPAGE_INSTALL_DIR_USER="$HOME/.local/share/man/man1" 
if [ -f "$MANPAGE_SOURCE" ]; then
    echo "Instalando página de manual en '${MANPAGE_INSTALL_DIR_USER}'..."
    mkdir -p "$MANPAGE_INSTALL_DIR_USER"
    cp "$MANPAGE_SOURCE" "${MANPAGE_INSTALL_DIR_USER}/${LAUNCHER_NAME}.1"
    # Comprimir si gzip está disponible
    if command -v gzip &> /dev/null; then
        gzip -f "${MANPAGE_INSTALL_DIR_USER}/${LAUNCHER_NAME}.1" 
    else
        echo "Advertencia: gzip no encontrado, la página de manual no se comprimirá."
    fi
    echo "Página de manual instalada. Puede que necesites añadir '$HOME/.local/share/man' a tu MANPATH."
    echo "O ejecutar 'mandb' si está disponible y configurado para directorios de usuario."
fi

# --- Comprobación y Configuración del PATH ---
ensure_dir_in_path "$USER_BIN_DIR"


echo ""
echo "¡Instalación de 'ask' completada!"
echo "El lanzador es: ${USER_BIN_DIR}/${LAUNCHER_NAME}"
echo "Los archivos principales están en: ${APP_INSTALL_DIR}/"

if [ -z "$NEW_API_KEY_TO_SAVE" ] && [ "$API_KEY_CONFIGURED_IN_FILE" = false ] && [ ! -f "$API_KEY_FILE_PATH" ]; then
 echo "IMPORTANTE: No se configuró la GEMINI_API_KEY. Necesitarás hacerlo manualmente o reinstalar."
fi
echo "El script 'ask' intentará cargar la API Key desde '${APP_INSTALL_DIR}/${API_KEY_FILENAME}'."
echo ""
echo "Para desinstalar, ejecuta:"
echo "  rm ${USER_BIN_DIR}/${LAUNCHER_NAME}"
echo "  rm -rf ${APP_INSTALL_DIR}"
if [ -f "${MANPAGE_INSTALL_DIR_USER}/${LAUNCHER_NAME}.1.gz" ]; then
    echo "  rm ${MANPAGE_INSTALL_DIR_USER}/${LAUNCHER_NAME}.1.gz"
elif [ -f "${MANPAGE_INSTALL_DIR_USER}/${LAUNCHER_NAME}.1" ]; then
    echo "  rm ${MANPAGE_INSTALL_DIR_USER}/${LAUNCHER_NAME}.1"
fi
echo "Y revisa tu archivo de configuración del shell (~/.bashrc o ~/.zshrc) por si se añadió la línea del PATH."

exit 0