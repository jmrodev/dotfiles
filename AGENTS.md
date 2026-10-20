# Reglas de Colaboración de Agentes (ACP / OpenCode)

## Flujo de Trabajo Continuo con ACP
* **Co-Piloto / Agente Compañero:** Siempre colaborar activamente con OpenCode utilizando el protocolo de agentes (ACP) o su interfaz CLI (`opencode`).
* **Dinámica de trabajo:**
  - En tareas de programación, refactorización, diseño de arquitectura o revisión de código, consultar o delegar en OpenCode para contrastar enfoques, generar soluciones y validar implementaciones.
  - Antigravity orquesta la interacción con el usuario, coordina la ejecución y sintetiza las soluciones.
* **Modelos en OpenCode:**
  - Utilizar por defecto los modelos gratuitos disponibles (por ejemplo, Google Gemini a través de `GOOGLE_GENERATIVE_AI_API_KEY`, o los modelos gratuitos de OpenCode Zen como DeepSeek V4 Flash, MiMo, Nemotron).

## Copia al Portapapeles
* **Snippets y One-liners para el usuario:** Siempre que se entregue un one-liner, bookmarklet, script de una línea o comando sensible a saltos de línea de la terminal, copiarlo directamente al portapapeles del sistema usando `wl-copy` para evitar que se cuelen espacios o saltos de línea al copiar manualmente.

## Entorno de Terminal y Multiplexer Oficial
* **Emulador de Terminal:** **Kitty** (`/usr/bin/kitty`).
  - **Shell:** Fish (`/usr/bin/fish`).
  - **Fuente:** `JetBrainsMono Nerd Font` (tamaño 14.0).
  - **Opacidad:** `background_opacity 0.9`.
  - **Portapapeles inteligente:** Selección con mouse copia automáticamente, `Ctrl+C` copia si hay texto seleccionado o interrumpe proceso si no lo hay; `Ctrl+V` pega.
  - **Theming:** Sincronizado automáticamente claro/oscuro vía `~/.config/kitty/current-theme.conf`.
* **Multiplexer y Gestor de Agentes:** **Herdr** (`~/.config/herdr/config.toml`).
  - Invocación desde Sway: `kitty -e herdr`.
  - Tema: `vesper`.
  - Atajo base: `Ctrl+b`.
  - Workspaces para agentes: `Super+o` (OpenCode), `Super+g` (Antigravity), `Super+c` (AgyCode).
* **Emuladores y multiplexers deprecados/eliminados:** Foot, Alacritty, Tmux, Ranger, Zellij y Xterm NO deben reinstalarse ni referenciarse.

## Flujo de Dotfiles y Estado del Sistema (`homestate`)
* **Detección de cambios y candidatos:** Antes de sincronizar o evaluar qué archivos van a los dotfiles, usar `homestate json` o `homestate diff` para ver altas y modificaciones en `~/.config`, `~/.local/bin` y dotfiles de raíz.
* **Seguridad de credenciales:** Antes de agregar cualquier script o configuración, verificar que no contenga API keys, tokens o contraseñas hardcodeadas; de haberlas, moverlas a `~/.config/fish/conf.d/secrets.fish` y consumirlas mediante variables de entorno.
* **Sincronización:** Tras cualquier cambio o limpieza de dotfiles, commitear en el repositorio bare (`~/.dotfiles`), actualizar la foto base con `homestate snapshot` y pushear a `origin main`.


<!-- BEGIN AWS Agent Toolkit rules -->
# AWS Guidance

- Where these AWS rules conflict with the project's own instructions, the
  project's instructions take precedence.
- Prefer the AWS MCP Server for AWS interactions — it provides sandboxed
  execution, observability, and audit logging. If unavailable, use the
  AWS CLI directly.
- Before starting a task, check whether a relevant AWS skill is available.
  Load the skill with `retrieve_skill` and prefer its guidance over
  general knowledge.
- When uncertain about specific AWS details (API parameters, permissions,
  limits, error codes), verify against documentation rather than guessing.
  State uncertainty explicitly if you cannot confirm.
- When creating infrastructure, prefer infrastructure-as-code (AWS CDK or
  CloudFormation) over direct CLI commands.
- When working with infrastructure, follow AWS Well-Architected Framework
  principles.
- Do not use em dashes in AWS resource names or descriptions. Use
  hyphens instead.

## Secret Safety

- MUST load the `aws-secrets-manager` skill first for any secret,
  credential, API key, token, or password task. MUST NOT call
  `secretsmanager get-secret-value` or `batch-get-secret-value`, and MUST
  NOT hit the Secrets Manager Agent daemon directly. MUST use
  `{{resolve:secretsmanager:secret-id:SecretString:json-key}}` with
  `asm-exec` so the secret resolves at runtime without entering context.
<!-- END AWS Agent Toolkit rules -->
