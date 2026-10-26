# 🎵 Guía de Música (YouTube & Navidrome)

Herramientas locales para descargar álbumes en MP3 320 kbps con carátula y metadatos limpios para Navidrome.

---

## 🎧 1. Asistente Conversacional Flotante (`feishin-ai`)
* **Atajo en Sway:** Pulsa **`$mod + m`** mientras escuchas música en Feishin para abrir el asistente flotante.
* **100% Conversacional:** Sin formularios ni preguntas burocráticas de teclado (no te pide escribir año ni género).
  * Ejemplo: *"Recomiéndame un disco de los 80 de rock argentino que no tenga"*.
  * La IA local (`qwen2.5-coder:3b`) consulta lo que tienes en tu PC con `fd`.
  * Busca las opciones oficiales en YouTube con `searcher.py`.
  * Te responde de forma natural: *"Encontré Canción Animal (1990) de Soda Stereo, ¿querés que lo baje?"*.
  * Le respondes *"dale"* o *"sí"* y lo descarga en MP3 320kbps con carátula y tags ID3.

---

## 🔎 2. Buscador Rápido Letra por Letra en tu PC (`fd` + `fzf`)
```bash
# Abrir buscador interactivo en tiempo real con previsualización de carátulas y canciones:
music-find

# O iniciar con filtro directo (ej: iron, queen, 80):
music-find iron
music-find "Brave New World"
```
* **Artistas:** Muestra de inmediato qué álbumes tienes en tu PC.
* **Álbumes:** Muestra el listado de temas y confirma si tiene `cover.jpg`.

---

## 🔍 3. Buscar Álbumes o Playlists en YouTube
```bash
yt-album-search "Queen A Kind of Magic full album"
yt-album-search "Charly García Clics Modernos"
```
Muestra los enlaces oficiales de las playlists completas (`- Topic`, Vevo) con insignia `[OFICIAL 💿]`.

---

## ⬇️ 4. Asistente Interactivo de Descargas (`navidrome-dl`)
```bash
# Modo interactivo paso a paso:
navidrome-dl
```
* Al escribir el nombre del artista (ej: `iron`), detecta si ya existe en tu PC y te muestra sus álbumes.
* Puedes escribir `?` en el artista o en el álbum para abrir **`fzf` letra por letra** sobre tu colección.
* Si el álbum ya existe en tu disco, te advierte y te pregunta si realmente deseas descargarlo de nuevo para evitar duplicados.

### Descarga directa por parámetros:
```bash
# Formato:
navidrome-dl --artist "Queen" --album "A Kind of Magic" --year 1986 --url "https://www.youtube.com/playlist?list=..."
```
* Descarga en **MP3 320 kbps** (desde audio Opus 48kHz).
* Extrae y guarda **`cover.jpg`**.
* Aplica etiquetas ID3v2 (Artista, Álbum, Año, Pistas numeradas `01/10`).
* Navidrome lo indexa automáticamente sin reiniciar.

---

## 📑 5. Crear o Actualizar Playlists (.m3u)
```bash
# Crear playlist de todos los temas de los 80:
m3u-maker --name "80s Rock" --decade 80s

# Crear playlist de un artista completo:
m3u-maker --name "AC-DC" --artist "AC-DC"

# Crear playlist por rango de años:
m3u-maker --name "Rock Clásico 70s" --years 1970-1979
```

---

## 📦 6. Descarga Masiva por Lotes (Batch)
```bash
navidrome-dl --batch ~/tools/musica/youtube/80s_rock_albums.json
```

---

## 🐧 7. Revisor de Código Linus Torvalds (`linus-review`)
```bash
# Revisar un script o diff con las reglas y skill de Linus Torvalds:
linus-review script.py
linus-review -d
```
