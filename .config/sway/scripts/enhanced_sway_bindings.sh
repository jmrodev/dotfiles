#!/bin/bash

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' 

SHOW_COMMENTED=false
TEMP_FILE="/tmp/sway_bindings_temp.txt"
CATEGORY_FILTER="Todas"
MODE_FILTER="Todos"

show_help() {
    echo -e "${BLUE}Uso: $0 [OPCIONES]${NC}"
    echo -e "Muestra los atajos de teclado de Sway en una interfaz Rofi"
    echo
    echo -e "${GREEN}Opciones:${NC}"
    echo -e "  -h, --help              Muestra esta ayuda"
    echo -e "  -c, --commented         Incluye atajos comentados"
    echo -e "  -p, --path RUTA         Especifica una ruta alternativa al archivo de configuración"
    echo
    echo -e "${YELLOW}Ejemplos:${NC}"
    echo -e "  $0                      Muestra atajos activos"
    echo -e "  $0 --commented          Muestra atajos activos y comentados"
    echo -e "  $0 --path ~/.config/sway/config.custom  Usa un archivo de configuración alternativo"
    exit 0
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            ;;
        -c|--commented)
            SHOW_COMMENTED=true
            shift
            ;;
        -p|--path)
            if [[ -n "$2" && -f "$2" ]]; then
                CONFIG_PATH="$2"
                shift 2
            else
                echo -e "${RED}Error: Archivo de configuración no encontrado: $2${NC}" >&2
                exit 1
            fi
            ;;
        *)
            echo -e "${RED}Error: Opción desconocida: $1${NC}" >&2
            echo "Usa '$0 --help' para ver las opciones disponibles."
            exit 1
            ;;
    esac
done

if [ -z "$CONFIG_PATH" ]; then
    CONFIG_PATH="${HOME}/.config/sway/config"
    if [ ! -f "$CONFIG_PATH" ]; then
        echo -e "${RED}Error: Archivo de configuración de Sway no encontrado en ${CONFIG_PATH}${NC}" >&2
        exit 1
    fi
fi

if ! command -v rofi &> /dev/null; then
    echo -e "${RED}Error: rofi no está instalado.${NC}" >&2
    echo "Instálalo con: sudo pacman -S rofi (Arch/Manjaro)"
    exit 1
fi

> "$TEMP_FILE"

extract_variables() {
    local file="$1"
    grep -E '^\s*set\s+\$\w+' "$file" | sed -E 's/^\s*set\s+(\$\w+)\s+(.*)/\1|\2/' | sed -E 's/"//g' | sed -E "s/'//g"
}

replace_variables() {
    local input="$1"
    local variables="$2"
    
    local mod_value=$(echo "$variables" | grep '^\$mod|' | cut -d'|' -f2)
    if [ -n "$mod_value" ]; then
        input=${input//\$mod/Mod}
    fi
    
    while IFS="|" read -r var_name var_value; do
        if [ -n "$var_name" ] && [ -n "$var_value" ] && [ "$var_name" != '$mod' ]; then
            input=${input//$var_name/$var_value}
        fi
    done <<< "$variables"
    
    echo "$input"
}

process_config_file() {
    local file="$1"
    local variables="$2"
    local current_mode="Default"
    local in_mode=false
    
    if [ -z "$variables" ]; then
        variables=$(extract_variables "$file")
    fi
    
    while read -r include_line; do
        include_path=$(echo "$include_line" | sed -E 's/^\s*include\s+//' | sed -E 's/"//g' | sed -E "s/'//g")
        # Expand ~ to $HOME
        include_path="${include_path/#\~/$HOME}"
        
        if [[ "$include_path" == /* ]]; then
            for expanded_path in $include_path; do
                if [ -f "$expanded_path" ]; then
                    local new_vars=$(extract_variables "$expanded_path")
                    if [ -n "$new_vars" ]; then
                        variables="$variables"$'\n'"$new_vars"
                    fi
                    process_config_file "$expanded_path" "$variables"
                fi
            done
        else
            dir=$(dirname "$file")
            # Allow globbing for relative path matching
            for expanded_path in $dir/$include_path; do
                if [ -f "$expanded_path" ]; then
                    local new_vars=$(extract_variables "$expanded_path")
                    if [ -n "$new_vars" ]; then
                        variables="$variables"$'\n'"$new_vars"
                    fi
                    process_config_file "$expanded_path" "$variables"
                fi
            done
        fi
    done < <(grep -E '^\s*include\s+' "$file")
    
    while IFS= read -r line; do
        if [[ "$line" =~ ^\s*mode\s+ ]]; then
            in_mode=true
            current_mode=$(echo "$line" | sed -E 's/^\s*mode\s+"([^"]+)".*/\1/' | sed -E "s/^\s*mode\s+'([^']+)'.*/\1/")
            continue
        fi
        
        if [[ "$in_mode" == true && "$line" =~ ^\s*\} ]]; then
            in_mode=false
            current_mode="Default"
            continue
        fi
        
        if [[ "$line" =~ ^\s*(#\s*)?(bindsym|bindcode) ]]; then
            is_commented=false
            if [[ "$line" =~ ^\s*# ]]; then
                is_commented=true
                if [ "$SHOW_COMMENTED" = false ]; then
                    continue
                fi
            fi
            
            bind_type=$(echo "$line" | sed -E 's/^\s*(#\s*)?(bindsym|bindcode).*/\2/')
            
            if [ "$is_commented" = true ]; then
                key_combo=$(echo "$line" | sed -E 's/^\s*#\s*(bindsym|bindcode)\s+([^ ]+).*/\2/')
                command=$(echo "$line" | sed -E 's/^\s*#\s*(bindsym|bindcode)\s+[^ ]+\s+(.*)/\2/')
            else
                key_combo=$(echo "$line" | sed -E 's/^\s*(bindsym|bindcode)\s+([^ ]+).*/\2/')
                command=$(echo "$line" | sed -E 's/^\s*(bindsym|bindcode)\s+[^ ]+\s+(.*)/\2/')
            fi
            
            key_combo=$(replace_variables "$key_combo" "$variables")
            command=$(echo "$command" | sed -E 's/--release\s+//')
            command=$(echo "$command" | sed -E 's/exec\s*(--no-startup-id\s*)?//')
            
            category="Otro"
            if [[ "$command" =~ workspace ]]; then
                category="Workspace"
            elif [[ "$command" =~ focus|move|resize|split|layout|floating|fullscreen ]]; then
                category="Ventana"
            elif [[ "$command" =~ swaynag|swaybar|swaystatus|swaylock|swaymsg ]]; then
                category="Sway"
            elif [[ "$command" =~ exec ]]; then
                category="Aplicación"
            elif [[ "$command" =~ reload|restart|exit|kill ]]; then
                category="Sistema"
            fi
            
            status="[ACTIVO]"
            if [ "$is_commented" = true ]; then
                status="[COMENTADO]"
            fi
            
            type_indicator="[SYM]"
            if [ "$bind_type" = "bindcode" ]; then
                type_indicator="[CODE]"
            fi
            
            echo "$category|$current_mode|$status|$type_indicator|$key_combo|$command" >> "$TEMP_FILE"
        fi
    done < "$file"
}

process_config_file "$CONFIG_PATH"

show_rofi_menu() {
    categories=$(cat "$TEMP_FILE" | cut -d'|' -f1 | sort | uniq)
    modes=$(cat "$TEMP_FILE" | cut -d'|' -f2 | sort | uniq)
    
    menu_options="FILTRAR POR CATEGORÍA\nFILTRAR POR MODO\nMOSTRAR TODOS LOS ATAJOS"
    if [ "$SHOW_COMMENTED" = true ]; then
        menu_options="$menu_options\nOCULTAR ATAJOS COMENTADOS"
    else
        menu_options="$menu_options\nMOSTRAR ATAJOS COMENTADOS"
    fi
    
    selection=$(echo -e "$menu_options" | rofi -dmenu -i -p "Atajos Sway" \
        -mesg "Categoría actual: $CATEGORY_FILTER | Modo actual: $MODE_FILTER | Comentados: $SHOW_COMMENTED" \
        -theme-str '
            window {
                width: 50%;
                border-radius: 8px;
            }
            listview {
                lines: 10;
                scrollbar: true;
            }
            element {
                padding: 8px;
            }
            element-text {
                highlight: bold;
            }
        ')
    
    case "$selection" in
        "FILTRAR POR CATEGORÍA")
            category_menu="Todas\n$(echo "$categories" | tr '\n' '\n')"
            selected_category=$(echo -e "$category_menu" | rofi -dmenu -i -p "Selecciona categoría" \
                -theme-str 'window {width: 30%; border-radius: 8px;} listview {lines: 10;}')
            if [ -n "$selected_category" ]; then
                CATEGORY_FILTER="$selected_category"
            fi
            show_bindings
            ;;
        "FILTRAR POR MODO")
            mode_menu="Todos\n$(echo "$modes" | tr '\n' '\n')"
            selected_mode=$(echo -e "$mode_menu" | rofi -dmenu -i -p "Selecciona modo" \
                -theme-str 'window {width: 30%; border-radius: 8px;} listview {lines: 10;}')
            if [ -n "$selected_mode" ]; then
                MODE_FILTER="$selected_mode"
            fi
            show_bindings
            ;;
        "MOSTRAR TODOS LOS ATAJOS")
            CATEGORY_FILTER="Todas"
            MODE_FILTER="Todos"
            show_bindings
            ;;
        "MOSTRAR ATAJOS COMENTADOS")
            SHOW_COMMENTED=true
            > "$TEMP_FILE"
            process_config_file "$CONFIG_PATH"
            show_bindings
            ;;
        "OCULTAR ATAJOS COMENTADOS")
            SHOW_COMMENTED=false
            > "$TEMP_FILE"
            process_config_file "$CONFIG_PATH"
            show_bindings
            ;;
        *)
            show_bindings
            ;;
    esac
}

show_bindings() {
    filtered_content=""
    
    while IFS="|" read -r category mode status type key command; do
        if [ "$CATEGORY_FILTER" != "Todas" ] && [ "$category" != "$CATEGORY_FILTER" ]; then
            continue
        fi
        
        if [ "$MODE_FILTER" != "Todos" ] && [ "$mode" != "$MODE_FILTER" ]; then
            continue
        fi
        
        if [ "$mode" = "Default" ]; then
            formatted_line="$status $type $key -> $command"
        else
            formatted_line="$status $type [$mode] $key -> $command"
        fi
        
        if [ -z "$filtered_content" ]; then
            filtered_content="$formatted_line"
        else
            filtered_content="$filtered_content\n$formatted_line"
        fi
    done < "$TEMP_FILE"
    
    if [ -z "$filtered_content" ]; then
        filtered_content="No se encontraron atajos con los filtros actuales"
    fi
    
    selected_binding=$(echo -e "$filtered_content" | rofi -dmenu -i -p "Atajos Sway" \
        -mesg "Categoría: $CATEGORY_FILTER | Modo: $MODE_FILTER | Comentados: $SHOW_COMMENTED | F1: Menú | ESC: Salir" \
        -kb-custom-1 "F1" \
        -kb-secondary-copy "" \
        -kb-cancel "Escape,Control+g,Control+c" \
        -theme-str '
            window {
                width: 80%;
                height: 70%;
                border-radius: 8px;
            }
            listview {
                columns: 1;
                layout: vertical;
                lines: 20;
                scrollbar: true;
                dynamic: true;
            }
            element {
                orientation: horizontal;
                padding: 6px;
            }
            element-icon {
                size: 0px;
            }
            element-text {
                highlight: bold;
            }
            inputbar {
                children: [prompt, entry];
                padding: 8px;
            }
            entry {
                placeholder: "Buscar atajo...";
                cursor: text;
            }
        ')
    
    exit_code=$?
    if [ $exit_code -eq 10 ]; then
        show_rofi_menu
    elif [ $exit_code -eq 0 ] && [ -n "$selected_binding" ] && [ "$selected_binding" != "No se encontraron atajos con los filtros actuales" ]; then
        # Copiar al portapapeles usando wl-copy (Wayland) o xclip (X11)
        if command -v wl-copy &> /dev/null; then
            echo -n "$selected_binding" | wl-copy
        elif command -v xclip &> /dev/null; then
            echo -n "$selected_binding" | xclip -selection clipboard
        fi
        
        # Enviar notificación de escritorio
        if command -v notify-send &> /dev/null; then
            notify-send "Atajo de teclado copiado" "$selected_binding" -i dialog-information
        fi
        exit 0
    fi
}

show_bindings
