# Dotfiles Multienorno (i3wm / Sway)

Estos son mis dotfiles personales optimizados para un entorno de desarrollo profesional. El repositorio utiliza ramas para soportar diferentes sistemas de ventanas:

- **Rama `i3wm`**: Configuración optimizada para X11 (Arch Linux, Debian).
- **Rama `sway`**: Configuración moderna para Wayland (Manjaro, Sway).

## Componentes Compartidos
Independientemente del sistema de ventanas, estos dotfiles incluyen:
- **Shell**: `zsh` con Oh My Zsh, Powerlevel10k y plugins.
- **Editor**: `Neovim` con NvChad/LazyVim.
- **Tools**: Entorno LAMP, scripts de gestión de GitHub (Gists, Issues), pnpm, pyenv.

## Gestión de Dotfiles
Se utiliza la técnica de "Bare Repository" para gestionar los archivos directamente en el `$HOME`.

### Instalación
1. **Clonar**: `git clone --bare https://github.com/jmrodev/dotfiles.git $HOME/.dotfiles`
2. **Alias**: El alias `config` se añade automáticamente a tu `.zshrc`.
3. **Checkout**: 
   - Para i3wm: `config checkout i3wm`
   - Para Sway: `config checkout sway`

## Uso
- `config status`: Ver cambios.
- `config add <archivo>`: Rastrear nuevo archivo.
- `config commit -m "mensaje"`: Guardar cambios.
- `config push origin <rama>`: Subir cambios a la rama correspondiente.

---
Mantenido por [jmrodev](https://github.com/jmrodev)
