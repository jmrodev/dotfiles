# 🎵 Guía de Música (YouTube & Navidrome)

Herramientas locales para descargar álbumes en MP3 320 kbps con carátula y metadatos limpios para Navidrome.

---

## 🔍 1. Buscar Álbumes o Playlists en YouTube
```bash
yt-album-search "Queen A Kind of Magic full album"
yt-album-search "Charly García Clics Modernos"
```
Muestra los enlaces oficiales de las playlists completas con cantidad de temas.

---

## ⬇️ 2. Descargar Álbum Completo para Navidrome
```bash
# Formato general:
navidrome-dl --artist "Artista" --album "Álbum" --year AÑO --url "URL_PLAYLIST"

# Ejemplo:
navidrome-dl --artist "Queen" --album "A Kind of Magic" --year 1986 --url "https://www.youtube.com/playlist?list=..."
```
* Descarga en **MP3 320 kbps**.
* Extrae y guarda **`cover.jpg`**.
* Aplica etiquetas ID3v2 (Artista, Álbum, Año, Pistas numeradas `01/10`).
* Navidrome lo indexa automáticamente sin reiniciar.

---

## 📑 3. Crear o Actualizar Playlists (.m3u)
```bash
# Crear playlist de todos los temas de los 80:
m3u-maker --name "80s Rock" --decade 80s

# Crear playlist de un artista completo:
m3u-maker --name "AC-DC" --artist "AC-DC"

# Crear playlist por rango de años:
m3u-maker --name "Rock Clásico 70s" --years 1970-1979
```

---

## 📦 4. Descarga Masiva por Lotes (Batch)
```bash
navidrome-dl --batch ~/tools/musica/youtube/80s_rock_albums.json
```
