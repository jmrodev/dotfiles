# 🐑 HERDR — Workspace Manager para Agentes de IA

Multiplexer moderno en Rust con detección nativa del estado de agentes (idle, ocupado, esperando input).

## 🚀 Inicio y Ciclo de Vida (CLI)
- `herdr`: Iniciar o reconectarse a la sesión persistente.
- `herdr status`: Ver estado del cliente local y del servidor en background.
- `herdr agent list`: Listar estado de agentes en ejecución en todos los workspaces.
- `herdr worktree list`: Gestionar y listar git worktrees aislados.
- `herdr server reload-config`: Recargar `config.toml` en caliente.
- `herdr server stop`: Detener completamente el servidor y cerrar sesiones.

---

## ⌨️ Atajos Básicos (Prefix: `Ctrl + b`)

### 🧭 Ayuda y Navegación General
- `Ctrl+b ?`: Mostrar overlay de ayuda interactiva con todos los atajos.
- `Ctrl+b s`: Abrir menú de configuración.
- `Ctrl+b q`: Desconectarse (Detach). La sesión sigue viva en segundo plano.
- `Ctrl+b b`: Ocultar / Mostrar la barra lateral (sidebar).
- `Ctrl+b r`: Modo redimensionar panel (flechas para ajustar, Enter/Esc para salir).

### 🪟 Paneles (Splits)
- `Ctrl+b v`: Dividir panel verticalmente.
- `Ctrl+b -`: Dividir panel horizontalmente.
- `Ctrl+b x`: Cerrar el panel activo.
- `Ctrl+b z`: Zoom / Pantalla completa del panel activo.
- `Ctrl+b h / j / k / l`: Mover foco entre paneles (izq, abajo, arriba, der).
- `Ctrl+b Tab`: Rotar foco al siguiente panel.

### 📑 Pestañas (Tabs)
- `Ctrl+b c`: Crear nueva pestaña.
- `Ctrl+b p` / `Ctrl+b n`: Pestaña anterior / siguiente.
- `Ctrl+b 1..9`: Saltar directamente a la pestaña número N.
- `Ctrl+b Shift+x`: Cerrar pestaña actual.

### 🌐 Workspaces & Git Worktrees (Agentes)
- `Ctrl+b w`: Selector interactivo de Workspaces.
- `Ctrl+b Shift+n`: Crear un nuevo Workspace.
- `Ctrl+b Shift+g`: Crear un nuevo Workspace montado sobre un Git Worktree.
- `Ctrl+b Shift+w`: Renombrar Workspace actual.
- `Ctrl+b Shift+d`: Cerrar Workspace actual.
