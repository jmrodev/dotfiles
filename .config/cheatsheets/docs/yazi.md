# 📁 YAZI — GESTOR DE ARCHIVOS DE TERMINAL

Yazi es el explorador oficial de archivos configurado para abrirse con `Super + e` (Kitty + Yazi).

---

## 🧭 NAVEGACIÓN BÁSICA
- `h` / `Left`: Subir al directorio padre
- `j` / `Down`: Bajar al siguiente archivo/carpeta
- `k` / `Up`: Subir al archivo/carpeta anterior
- `l` / `Right`: Entrar al directorio
- `<Enter>`: **Smart-Enter** (Entra si es carpeta / Abre si es archivo)
- `q`: Salir de Yazi
- `~`: Ver panel de ayuda interna con todos los atajos

---

## ✂️ OPERACIONES DE ARCHIVOS (COPIAR / CORTAR / PEGAR)
- `y`: Copiar archivo(s) seleccionado(s) (Yank)
- `x`: Cortar archivo(s) seleccionado(s)
- `p`: Pegar archivo(s) en la carpeta actual
- `P`: Pegar sobreescribiendo si ya existe
- `d`: Mover archivo(s) a la papelera (Trash)
- `D`: Eliminar permanentemente archivo(s) (Delete sin papelera)
- `a`: Crear nuevo archivo (o carpeta terminando en `/`)
- `r`: Renombrar archivo
- `R`: Renombrado masivo interactivo

---

## 📋 COPIAR RUTAS AL PORTAPAPELES (CLIPBOARD)
- `c d`: **Copiar la ruta del directorio actual** (`pwd`)
- `c c`: Copiar la ruta absoluta del archivo seleccionado
- `c f`: Copiar solo el nombre del archivo (`archivo.ext`)
- `c n`: Copiar solo el nombre sin extensión (`archivo`)

---

## 🔍 BÚSQUEDA Y FILTRADO
- `/`: Buscar archivos dentro del directorio actual
- `f`: Saltar al archivo escribiendo sus primeras letras (fzf integrado)
- `z`: Navegación rápida con Zoxide dentro de Yazi
- `.`: Mostrar / ocultar archivos ocultos (dotfiles)

---

## 📑 SELECCIÓN MÚLTIPLE
- `<Espacio>`: Seleccionar / Deseleccionar archivo actual
- `v`: Alternar modo de selección visual (para marcar bloques)
- `Ctrl + a`: Seleccionar todos los archivos del directorio
- `Ctrl + r`: Invertir la selección actual
