#!/usr/bin/env python3
import json
import glob
import os
import hashlib

def recolectar_comandos():
    base_dir = os.path.expanduser('~/coleccion_comandos')
    os.makedirs(base_dir, exist_ok=True)
    
    master_file = os.path.join(base_dir, 'comandos_master.txt')
    hashes_file = os.path.join(base_dir, '.hashes_vistos.set')

    # Cargar hashes existentes para no duplicar nada previamente guardado
    seen_hashes = set()
    if os.path.exists(hashes_file):
        with open(hashes_file, 'r', encoding='utf-8') as f:
            seen_hashes = set(line.strip() for line in f if line.strip())

    # Contar comandos existentes para continuar la numeración
    existing_count = 0
    if os.path.exists(master_file):
        with open(master_file, 'r', encoding='utf-8', errors='ignore') as f:
            for line in f:
                if line.startswith("# === Comando "):
                    existing_count += 1

    transcript_files = sorted(
        glob.glob('/home/jmro/.gemini/antigravity-cli/brain/*/.system_generated/logs/transcript.jsonl'),
        key=os.path.getmtime
    )

    nuevos_comandos = []
    last_cmd = None

    for path in transcript_files:
        with open(path, 'r', encoding='utf-8', errors='ignore') as f:
            for line in f:
                try:
                    data = json.loads(line)
                    for tc in data.get('tool_calls', []):
                        args = tc.get('args') or tc.get('arguments') or {}
                        if 'CommandLine' in args and isinstance(args['CommandLine'], str):
                            cmd = args['CommandLine'].strip()
                            
                            # Ignorar comandos vacíos o basura común
                            if not cmd or cmd in ['echo ""', 'echo', 'pwd']:
                                continue
                            
                            # Evitar secuencias idénticas seguidas
                            if cmd == last_cmd:
                                continue
                            last_cmd = cmd

                            # Desescapar comillas/saltos de línea si viene en formato string JSON
                            if (cmd.startswith('"') and cmd.endswith('"')) or (cmd.startswith("'") and cmd.endswith("'")):
                                try:
                                    cmd = json.loads(cmd)
                                except Exception:
                                    pass

                            # Calcular hash para verificar si ya fue registrado alguna vez
                            cmd_hash = hashlib.sha256(cmd.encode('utf-8')).hexdigest()
                            if cmd_hash not in seen_hashes:
                                seen_hashes.add(cmd_hash)
                                nuevos_comandos.append((cmd_hash, cmd))
                except Exception:
                    pass

    if not nuevos_comandos:
        print("ℹ️ No hay comandos nuevos para agregar.")
        return

    # Guardar nuevos comandos en el archivo acumulativo
    with open(master_file, 'a', encoding='utf-8') as f_out, open(hashes_file, 'a', encoding='utf-8') as f_hash:
        for idx, (h, cmd) in enumerate(nuevos_comandos, start=existing_count + 1):
            f_out.write(f"# === Comando {idx} ===\n{cmd}\n\n")
            f_hash.write(h + '\n')

    print(f"✅ Se agregaron {len(nuevos_comandos)} nuevos comandos a {master_file}")
    print(f"📦 Total acumulado en la colección: {existing_count + len(nuevos_comandos)} comandos.")

if __name__ == '__main__':
    recolectar_comandos()
