# 🐚 BASH CHEATSHEET

## Control de Flujo & Procesos
- `Ctrl + c`: Interrumpir proceso actual (SIGINT).
- `Ctrl + z`: Enviar proceso a segundo plano pausado (SIGTSTP).
- `bg` / `fg`: Reanudar proceso en background / traer a primer plano.
- `jobs -l`: Listar trabajos en background con su PID.
- `nohup comando &`: Ejecutar comando inmune a desconexión de sesión.

## Historial & Atajos de Línea
- `Ctrl + r`: Búsqueda interactiva reversa en el historial.
- `Ctrl + a` / `Ctrl + e`: Ir al inicio / fin de la línea.
- `Ctrl + u` / `Ctrl + k`: Borrar desde el cursor al inicio / fin.
- `Ctrl + w`: Borrar la palabra anterior.
- `!$`: Reutilizar el último argumento del comando anterior.
- `!!`: Reejecutar el comando anterior completo.

## Redirecciones & Pipes
- `cmd > file`: Redirigir stdout (sobrescribe).
- `cmd >> file`: Redirigir stdout (agrega al final).
- `cmd 2>&1`: Redirigir stderr a stdout.
- `cmd &> file`: Redirigir stdout y stderr juntos al archivo.
- `cmd1 | tee file | cmd2`: Ver salida, guardarla en archivo y pasarla al siguiente pipe.
