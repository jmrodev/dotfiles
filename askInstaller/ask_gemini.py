import os
import json
import argparse
import requests 
from pathlib import Path
import sys

# --- Constantes ---
LOCAL_CONTEXT_FILENAME = ".ask_context.local"
LOCAL_MEMORY_FILENAME = ".ask_memory.jsonl"
MAX_HISTORY_TURNS = 5
SCRIPT_DIR = Path(__file__).resolve().parent
GENERAL_CONTEXT_FILENAME_BASENAME = ".ask_context.general"
GENERAL_CONTEXT_FILEPATH = SCRIPT_DIR / GENERAL_CONTEXT_FILENAME_BASENAME

GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY")

DEBUG_MODE = False

def _debug_py(message: str):
    if DEBUG_MODE:
        print(f"PY_DEBUG: {message}", file=sys.stderr)

def load_memory(memory_file_path: Path, max_turns: int) -> list:
    history = []
    _debug_py(f"Intentando cargar memoria desde: {memory_file_path}")
    if memory_file_path.exists() and memory_file_path.is_file():
        try:
            with open(memory_file_path, "r", encoding="utf-8") as f:
                all_entries = []
                for i, line_content in enumerate(f):
                    line_content = line_content.strip()
                    if line_content:
                        _debug_py(f"Procesando línea de memoria {i+1}: {line_content[:100]}...")
                        try:
                            all_entries.append(json.loads(line_content))
                        except json.JSONDecodeError as e:
                            print(f"Advertencia: Línea corrupta en memoria ignorada: {line_content[:70]}... Error: {e}", file=sys.stderr)
                            _debug_py(f"Error de JSONDecodeError en línea {i+1}: {e}")
                
                _debug_py(f"Total de entradas parseadas de memoria: {len(all_entries)}")
                start_index = max(0, len(all_entries) - max_turns)
                history = all_entries[start_index:]
                _debug_py(f"Historial a usar (últimas {len(history)} entradas de {max_turns} máx).")
        except Exception as e:
            print(f"Error al leer el archivo de memoria '{memory_file_path}': {e}", file=sys.stderr)
    else:
        _debug_py(f"Archivo de memoria no encontrado o no es un archivo: {memory_file_path}")
    return history

def save_memory_entry(memory_file_path: Path, user_prompt: str, model_response: str):
    entry = {"user_prompt": user_prompt, "model_response": model_response}
    _debug_py(f"Intentando guardar entrada en memoria: {str(entry)[:100]}...")
    try:
        # No es necesario sanitizar con iconv aquí si Python maneja bien UTF-8,
        # y json.dumps(ensure_ascii=False) escribe UTF-8 directamente.
        # El problema de los M-XX es cómo la terminal o cat -vet los MUESTRA.
        # El archivo en sí debería contener los bytes UTF-8 correctos.
        with open(memory_file_path, "a", encoding="utf-8") as f:
            f.write(json.dumps(entry, ensure_ascii=False) + "\n") 
        _debug_py(f"Entrada guardada en memoria: {memory_file_path}")
    except Exception as e:
        print(f"Error al escribir en el archivo de memoria '{memory_file_path}': {e}", file=sys.stderr)

def load_file_content(file_path_str: str | None, file_description: str = "archivo") -> str:
    if not file_path_str:
        return ""
    file_path = Path(file_path_str)
    _debug_py(f"Intentando cargar contenido de '{file_description}' desde: {file_path}")
    if file_path.exists() and file_path.is_file():
        try:
            content = file_path.read_text(encoding="utf-8")
            _debug_py(f"Contenido de '{file_description}' cargado (longitud: {len(content)}).")
            return content
        except Exception as e:
            print(f"Error al leer '{file_description}' en '{file_path}': {e}", file=sys.stderr)
            return ""
    else:
        _debug_py(f"'{file_description}' no encontrado o no es un archivo: {file_path}")
        return ""

def confirm_action(prompt_message: str) -> bool:
    try:
        confirmation = input(f"{prompt_message} (s/N): ")
        return confirmation.lower() in ['s', 'si']
    except EOFError:
        print(f"No se puede confirmar la acción interactivamente. Omitiendo.", file=sys.stderr)
        return False

def confirm_overwrite_python(item_name: str, item_path: Path) -> bool:
    return confirm_action(f"El archivo '{item_name} ({item_path})' ya existe. ¿Quieres SOBRESCRIBIRLO?")

def save_text_to_file(file_path: Path, content: str, file_description: str, mode: str = "w"):
    _debug_py(f"Intentando guardar '{file_description}' en '{file_path}' con modo '{mode}'")
    
    if mode == "w" and file_path.exists():
        if not confirm_overwrite_python(file_description, file_path): # Pasar file_path para el mensaje
            print(f"Guardado (sobrescritura) de '{file_description}' cancelado.", file=sys.stderr)
            _debug_py(f"Sobrescritura de '{file_path}' cancelada por el usuario.")
            return False
    
    try:
        file_path.parent.mkdir(parents=True, exist_ok=True)
    except Exception as e_mkdir:
        print(f"Error al crear directorio para '{file_path.parent}': {e_mkdir}", file=sys.stderr)
        return False

    try:
        # Si es modo append y el archivo existe y no está vacío, añadir un separador.
        add_separator = False
        if mode == "a" and file_path.exists() and file_path.stat().st_size > 0:
            # Leer el último carácter para ver si ya es una nueva línea
            with open(file_path, "rb") as f: # Leer en modo binario para el último byte
                f.seek(-1, os.SEEK_END)
                if f.read(1) != b'\n':
                    add_separator = True # Necesita al menos una nueva línea
                f.seek(-2, os.SEEK_END) # Ver los últimos dos para doble nueva línea
                if f.read(2) != b'\n\n':
                    add_separator = True # Necesita una segunda nueva línea para el párrafo
        
        with open(file_path, mode, encoding="utf-8") as f:
            if add_separator:
                f.write("\n\n") 
                _debug_py(f"Añadiendo separador antes de agregar a '{file_path}'")
            f.write(content)
        
        action_verb = "Contenido guardado (sobrescrito)" if mode == "w" else "Contenido agregado"
        print(f"{action_verb} en '{file_description}': {file_path}", file=sys.stderr)
        _debug_py(f"Contenido procesado {mode} exitosamente en '{file_path}'.")
        return True
    except Exception as e:
        print(f"Error al guardar '{file_description}' en '{file_path}' (modo {mode}): {e}", file=sys.stderr)
        return False

def handle_save_or_append_context_command(target_type: str, content_to_process: str | None, mode: str):
    if content_to_process is None: # El texto es obligatorio para estos comandos
        action_verb = "guardar" if mode == "w" else "agregar"
        print(f"Error: No se proporcionó texto para {action_verb} como contexto {target_type}. "
              f"Use --{action_verb}-{target_type} \"SU TEXTO AQUÍ\"", file=sys.stderr)
        sys.exit(1)

    file_path = None
    description = ""

    if target_type == "local":
        file_path = Path.cwd() / LOCAL_CONTEXT_FILENAME
        description = "Contexto Local"
    elif target_type == "general":
        file_path = GENERAL_CONTEXT_FILEPATH
        description = "Contexto General"
    else:
        print(f"Error: Tipo de objetivo de guardado/agregado desconocido: {target_type}", file=sys.stderr)
        sys.exit(1)
    
    if save_text_to_file(file_path, content_to_process, description, mode=mode):
        sys.exit(0) # Salir con éxito si se guardó
    else:
        sys.exit(1) # Salir con error si no se guardó


def delete_file_if_exists_python(file_to_delete: Path, file_description: str):
    _debug_py(f"Intentando borrar '{file_description}' en '{file_to_delete}'")
    if file_to_delete.exists() and file_to_delete.is_file():
        if confirm_action(f"¿Estás seguro de que quieres borrar '{file_description} ({file_to_delete})'?"):
            try:
                file_to_delete.unlink()
                print(f"Archivo '{file_description}' borrado: {file_to_delete}", file=sys.stderr)
            except Exception as e:
                print(f"Error: No se pudo borrar '{file_description}': {file_to_delete}. Error: {e}", file=sys.stderr)
        else:
            print(f"Borrado de '{file_description}' cancelado.", file=sys.stderr)
    else:
        print(f"Archivo '{file_description}' no encontrado en '{file_to_delete}'. Nada que borrar.", file=sys.stderr)

def handle_clean_command(target: str):
    _debug_py(f"Manejando comando --clean con objetivo: {target}")
    if target == "local-context":
        delete_file_if_exists_python(Path.cwd() / LOCAL_CONTEXT_FILENAME, "Contexto Local")
    elif target == "general-context":
        delete_file_if_exists_python(GENERAL_CONTEXT_FILEPATH, "Contexto General")
    elif target == "memory":
        delete_file_if_exists_python(Path.cwd() / LOCAL_MEMORY_FILENAME, "Memoria Local")
    elif target == "all":
        delete_file_if_exists_python(Path.cwd() / LOCAL_CONTEXT_FILENAME, "Contexto Local")
        delete_file_if_exists_python(GENERAL_CONTEXT_FILEPATH, "Contexto General")
        delete_file_if_exists_python(Path.cwd() / LOCAL_MEMORY_FILENAME, "Memoria Local")
    else:
        print(f"Error: Objetivo de --clean desconocido: '{target}'.", file=sys.stderr)
        print("Opciones válidas: local-context, general-context, memory, all.", file=sys.stderr)
        sys.exit(1)
    sys.exit(0)

def main():
    global DEBUG_MODE
    global GEMINI_API_KEY 

    parser = argparse.ArgumentParser(
        description="Interactuar con la API de Gemini desde la terminal.",
        formatter_class=argparse.RawTextHelpFormatter,
        # No añadir add_help=False aquí, argparse lo maneja bien
    )
    
    # Mutuamente excluyentes para los comandos de acción principales
    action_exclusive_group = parser.add_mutually_exclusive_group()
    action_exclusive_group.add_argument("--clean", metavar="TARGET",
                                       help="Borra archivos. TARGET: local-context, general-context, memory, all.")
    action_exclusive_group.add_argument("--save-local", metavar="\"TEXTO\"",
                                       help=f"SOBREESCRIBE el contexto local (./{LOCAL_CONTEXT_FILENAME}) con TEXTO.")
    action_exclusive_group.add_argument("--append-local", metavar="\"TEXTO\"",
                                       help=f"AGREGA TEXTO al contexto local (./{LOCAL_CONTEXT_FILENAME}).")
    action_exclusive_group.add_argument("--save-general", metavar="\"TEXTO\"",
                                       help=f"SOBREESCRIBE el contexto general ({GENERAL_CONTEXT_FILEPATH}) con TEXTO.")
    action_exclusive_group.add_argument("--append-general", metavar="\"TEXTO\"",
                                       help=f"AGREGA TEXTO al contexto general ({GENERAL_CONTEXT_FILEPATH}).")

    query_group = parser.add_argument_group('Opciones de Consulta a Gemini (se pueden usar con un prompt)')
    query_group.add_argument("--file", metavar="RUTA_ARCHIVO",
                             help="Ruta a un archivo cuyo contenido se incluirá en el prompt.")
    query_group.add_argument("--load-general-context", action="store_true",
                             help=f"Carga el contexto general.")
    query_group.add_argument("--no-local-context", action="store_true",
                             help=f"No carga el contexto local.")
    query_group.add_argument("--no-memory", action="store_true",
                             help=f"No carga ni guarda la memoria de conversación.")
    query_group.add_argument("--debug", action="store_true",
                             help="Activa la salida de depuración detallada para el script de Python.")
    
    parser.add_argument("prompt_text", nargs="*", 
                        help="La pregunta para Gemini. Ignorada si se usa un comando de acción como --clean o --save-*.")

    parser.epilog = (f"Archivos de contexto y memoria:\n"
                     f"  Contexto Local: ./{LOCAL_CONTEXT_FILENAME}\n"
                     f"  Contexto General: {GENERAL_CONTEXT_FILEPATH}\n"
                     f"  Memoria Local: ./{LOCAL_MEMORY_FILENAME}\n\n"
                     f"Requiere que GEMINI_API_KEY esté en el entorno.")

    args = parser.parse_args()

    if args.debug:
        DEBUG_MODE = True

    _debug_py(f"Argumentos parseados: {args}")

    if not GEMINI_API_KEY:
        # Permitir que --help funcione sin API_KEY
        if not (len(sys.argv) > 1 and sys.argv[1] in ('-h', '--help')):
            print("Error: La variable de entorno GEMINI_API_KEY no está configurada.", file=sys.stderr)
            sys.exit(1)
    
    api_url_with_key = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key={GEMINI_API_KEY}" if GEMINI_API_KEY else None


    action_taken = False
    if args.clean:
        handle_clean_command(args.clean) # sale dentro de la función
        action_taken = True 
    if args.save_local is not None:
        handle_save_or_append_context_command("local", args.save_local, "w") # sale dentro
        action_taken = True
    if args.append_local is not None:
        handle_save_or_append_context_command("local", args.append_local, "a") # sale dentro
        action_taken = True
    if args.save_general is not None:
        handle_save_or_append_context_command("general", args.save_general, "w") # sale dentro
        action_taken = True
    if args.append_general is not None:
        handle_save_or_append_context_command("general", args.append_general, "a") # sale dentro
        action_taken = True
    
    # Si no se tomó ninguna acción y no hay texto de prompt, mostrar ayuda.
    user_question = " ".join(args.prompt_text)
    if not action_taken and not user_question:
        # Si el único argumento fue, por ejemplo, --debug sin prompt, mostrar ayuda.
        if len(sys.argv) <=2 and args.debug : # sys.argv[0] es el nombre del script, sys.argv[1] sería --debug
             parser.print_help(sys.stderr)
             sys.exit(0) # Salir con 0 para ayuda
        elif len(sys.argv) == 1: # Caso 'ask' solo
            parser.print_help(sys.stderr)
            sys.exit(1)
        # Si hay otros flags de consulta pero no prompt_text
        print("Error: Se requiere una pregunta para la consulta a Gemini.", file=sys.stderr)
        parser.print_help(sys.stderr)
        sys.exit(1)
    
    if action_taken: # Si una acción como --save-* se ejecutó y salió, no continuar.
        # Esto es redundante porque handle_save_or_append_context_command ya sale,
        # pero es una doble comprobación por si se modifica esa lógica.
        return

    if not api_url_with_key: # Necesario para la consulta
        print("Error: GEMINI_API_KEY no está configurada, no se puede continuar con la consulta.", file=sys.stderr)
        sys.exit(1)

    _debug_py(f"Pregunta del usuario para Gemini: {user_question}")
    
    final_llm_input_parts = []
    model_text_response = "" 

    _debug_py("--- Iniciando Carga de Memoria (Python) ---")
    if not args.no_memory:
        memory_file = Path.cwd() / LOCAL_MEMORY_FILENAME
        history = load_memory(memory_file, MAX_HISTORY_TURNS)
        if history:
            history_text_parts = ["Historial de la conversación anterior:"]
            for entry in history:
                history_text_parts.append(f"Usuario: {entry.get('user_prompt', '')}")
                history_text_parts.append(f"Modelo: {entry.get('model_response', '')}")
            history_text_parts.append("--- Fin del historial ---") # Quitado \n aquí, se maneja con join
            final_llm_input_parts.append("\n".join(history_text_parts))
    _debug_py("--- Fin Carga de Memoria (Python) ---")

    _debug_py("--- Iniciando Carga de Contextos (Python) ---")
    if args.load_general_context:
        general_context_content = load_file_content(str(GENERAL_CONTEXT_FILEPATH), "Contexto General")
        if general_context_content:
            final_llm_input_parts.append(general_context_content) # Quitado \n aquí

    if not args.no_local_context:
        local_context_file = Path.cwd() / LOCAL_CONTEXT_FILENAME
        local_context_content = load_file_content(str(local_context_file), "Contexto Local")
        if local_context_content:
            final_llm_input_parts.append(local_context_content) # Quitado \n aquí
    _debug_py("--- Fin Carga de Contextos (Python) ---")
    
    _debug_py("--- Iniciando Carga de Archivo --file (Python) ---")
    file_content_for_prompt = load_file_content(args.file, "Archivo --file")
    if file_content_for_prompt:
        file_basename = Path(args.file).name if args.file else "archivo"
        final_llm_input_parts.append(f"Contenido del archivo '{file_basename}':\n```\n{file_content_for_prompt}\n```") # Quitado \n aquí
    _debug_py("--- Fin Carga de Archivo --file (Python) ---")

    _debug_py("--- Iniciando Construcción de final_llm_input (Python) ---")
    # La pregunta del usuario se añade al final de la lista de partes
    final_llm_input_parts.append(f"Pregunta actual:\n{user_question}")
    
    # Unir todas las partes con doble salto de línea, filtrando partes vacías.
    final_llm_input = "\n\n".join(filter(None, final_llm_input_parts))
    # Asegurar que si solo es la pregunta, no tenga "Pregunta actual:"
    if len(final_llm_input_parts) == 1 and final_llm_input_parts[0].startswith("Pregunta actual:\n"):
        final_llm_input = user_question
    
    if DEBUG_MODE:
        print(f"--- PY_DEBUG: FINAL LLM INPUT (longitud: {len(final_llm_input)}) ---", file=sys.stderr)
        llm_input_preview = final_llm_input
        if len(llm_input_preview) > 1000:
            llm_input_preview = f"{final_llm_input[:500]} ... (truncado) ... {final_llm_input[-500:]}"
        
        print(f"--- PY_DEBUG: FINAL LLM INPUT (cat -vet) ---", file=sys.stderr)
        temp_prompt_file = Path.cwd() / ".ask_temp_prompt_debug.txt"
        try:
            temp_prompt_file.write_text(llm_input_preview, encoding='utf-8')
            sys.stderr.flush()
            os.system(f"cat -vet \"{str(temp_prompt_file.resolve())}\" >&2")
        except Exception as e_cat:
            _debug_py(f"Error al mostrar final_llm_input con cat -vet: {e_cat}")
            print(llm_input_preview, file=sys.stderr) 
        finally:
            if temp_prompt_file.exists():
                try:
                    temp_prompt_file.unlink()
                except OSError: # En caso de problemas para borrar (ej. Windows)
                    pass 
        print(f"--- END PY_DEBUG: FINAL LLM INPUT (cat -vet) ---", file=sys.stderr)
    _debug_py("--- Fin Construcción de final_llm_input (Python) ---")


    payload = {"contents": [{"parts": [{"text": final_llm_input}]}]}
    _debug_py(f"Payload para API (primeros 200 chars del texto): {str(payload)[:200]}...")

    try:
        _debug_py(f"Enviando solicitud a API: {api_url_with_key}")
        response = requests.post(api_url_with_key, json=payload, headers={'Content-Type': 'application/json'}, timeout=60)
        _debug_py(f"Respuesta de API recibida, status: {response.status_code}")
        response.raise_for_status()
        api_response_json = response.json()
        
        if DEBUG_MODE:
            print(f"--- PY_DEBUG: API RESPONSE JSON ---", file=sys.stderr)
            print(json.dumps(api_response_json, indent=2, ensure_ascii=False), file=sys.stderr)
            print(f"--- END PY_DEBUG: API RESPONSE JSON ---", file=sys.stderr)

        model_text_response = api_response_json.get("candidates", [{}])[0].get("content", {}).get("parts", [{}])[0].get("text", "")

        if not model_text_response:
            if "error" in api_response_json:
                error_msg = api_response_json["error"].get("message", "Error desconocido de API.")
                print(f"Error de API: {error_msg}", file=sys.stderr)
            else:
                print("Error: No se pudo extraer texto de la respuesta de la API o la respuesta fue vacía.", file=sys.stderr)
                print(f"Respuesta completa: {json.dumps(api_response_json, indent=2, ensure_ascii=False)}", file=sys.stderr)
            sys.exit(1)

        print(model_text_response) 

        if not args.no_memory:
            memory_file_to_save = Path.cwd() / LOCAL_MEMORY_FILENAME
            save_memory_entry(memory_file_to_save, user_question, model_text_response)

    except requests.exceptions.RequestException as e:
        print(f"Error en la solicitud HTTP: {e}", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError:
        print(f"Error: No se pudo decodificar la respuesta JSON de la API.", file=sys.stderr)
        try:
            print(f"Respuesta cruda (primeros 500 chars): {response.text[:500]}...", file=sys.stderr)
        except NameError: 
            print("No hubo respuesta HTTP para mostrar.", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Ocurrió un error inesperado: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc(file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()