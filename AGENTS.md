# Guía Global de Comportamiento para Agentes e Inteligencias Artificiales (AGENTS.md)

Este documento contiene las reglas de conducta, directivas operativas y estándares que deben seguir **todos los agentes de IA, LLMs y asistentes de código** que interactúen con este sistema y sus proyectos.

---

## 1. REGLA DE ORO: Clarificación Previa Obligatoria

> **NUNCA ejecutar acciones ni asumir intenciones sin hacer antes las preguntas mínimas necesarias al usuario para tener una idea clara de lo que pide.**

### Pautas de Clarificación:
* **Prohibido asumir en tareas ambiguas:** Si el usuario hace una petición abierta (por ejemplo: "descargar música", "crear carpetas", "refactorizar el proyecto", "configurar una base de datos"), el agente **NO debe empezar a crear archivos, ejecutar scripts masivos ni realizar descargas a ciegas**.
* **Preguntas mínimas indispensables:** Antes de actuar, el agente debe formular preguntas concisas y directas para definir:
  1. **Alcance y selección:** ¿Qué elementos específicos o lote inicial prefiere?
  2. **Calidad y formato:** ¿Qué especificaciones técnicas prefiere (ej. MP3 320kbps vs FLAC, tipos de librerías, estándares de código)?
  3. **Destino y compatibilidad:** ¿Cómo interactúa esto con sus servicios o aplicaciones (ej. servidores Docker como Navidrome, servicios en la nube, clientes móviles)?
* **Confirmación de planes:** Presentar un breve resumen o propuesta antes de proceder con descargas o cambios de gran impacto.

---

## 2. Gestión de Medios y Servicios (Docker / Navidrome / Música)

* **Organización estructurada:** Los archivos multimedia deben respetar la jerarquía estándar:
  ```text
  /home/jmro/Music/
  └── Artista/
      └── (Año) Nombre del Álbum/
          ├── cover.jpg
          ├── 01 - Titulo de Pista.mp3
          └── ...
  ```
* **Calidad y Metadatos:**
  * Siempre asegurar metadatos ID3 completos (Artista, Álbum, Año, Número de Pista, Título, Género).
  * Incrustar carátulas en alta resolución (`cover.jpg` y tag ID3) para correcta visualización en Navidrome y clientes Subsonic.
  * Priorizar calidad de audio según lo acordado con el usuario (ej. MP3 a 320 kbps o FLAC).

---

## 3. Gestión de Configuración y Dotfiles (Git Bare)

* **Arquitectura Git Bare:** Las configuraciones del sistema se gestionan mediante un repositorio **Git Bare** en `~/.dotfiles` con `work-tree` en `$HOME` (`/home/jmro`).
* **Reglas de Agentes en Dotfiles:** 
  * El archivo maestro es `/home/jmro/AGENTS.md`.
  * Los accesos de compatibilidad (`~/CLAUDE.md`, `~/.cursorrules`, `~/.claude/CLAUDE.md`) son symlinks hacia `/home/jmro/AGENTS.md`.
  * Los cambios en estas configuraciones se gestionan mediante el comando del bare repo:
    ```bash
    git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME add AGENTS.md CLAUDE.md .cursorrules .claude/CLAUDE.md
    ```
* **Preservación:** No modificar dotfiles existentes (`.config/sway`, `.config/kitty`, `.config/fish`, etc.) sin instrucción y aprobación explícita del usuario.

---

## 4. Principios de Operación en el Sistema

* **No intrusión:** No alterar configuraciones globales ni borrar carpetas sin autorización explícita.
* **Preservación:** Cuidar el estado del sistema, dotfiles y repositorios existentes.
* **Comunicación:** Respuestas claras, concisas, directas y en español, priorizando la precisión sobre la verbosidad.
