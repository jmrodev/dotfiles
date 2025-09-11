#!/bin/bash

# Ruta al archivo del validador vnu.jar
VNU_JAR="/home/jmro/dist/vnu.jar"

# Carpeta que contiene los archivos HTML a validar
CARPETA_HTML="."

echo "Iniciando la validación de archivos HTML en el directorio actual..." 
echo "----------------------------------------------------"

# Encuentra todos los archivos .html en la carpeta y los pasa al validador
find "$CARPETA_HTML" -type f -name "*.html" -print0 | while IFS= read -r -d $'\0' archivo; do
    echo "Validando: $archivo"
    # El comando -jar ejecuta el archivo JAR con la opción --skip-non-html para ignorar archivos no HTML
    # Puedes añadir la opción --errors-only para mostrar solo los errores.
    java -jar "$VNU_JAR" --skip-non-html "$archivo"
    echo "" # Salto de línea para separar la salida de cada archivo
done

echo "----------------------------------------------------"
echo "Validación completada."
