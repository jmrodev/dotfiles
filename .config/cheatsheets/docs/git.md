# 🌿 GIT CHEATSHEET

## Ramas & Estados
- `git status -sb`: Estado resumido con información de rama.
- `git switch -c <rama>`: Crear y cambiar a una nueva rama.
- `git branch -vv`: Ver ramas locales con su tracking upstream y último commit.
- `git restore --staged <file>`: Quitar del stage sin perder cambios en el archivo.
- `git restore <file>`: Descartar cambios locales no guardados en el stage.

## Commits & Historial
- `git commit --amend`: Modificar el último commit (mensaje o cambios añadidos).
- `git log --oneline --graph --decorate --all`: Árbol visual de commits compacto.
- `git diff --stat`: Ver resumen de archivos modificados y cantidad de líneas.

## Stash & Limpieza
- `git stash push -m "mensaje"`: Guardar cambios sucios con etiqueta.
- `git stash list`: Ver stashes guardados.
- `git stash pop`: Aplicar y descartar el último stash.
- `git clean -fd`: Limpiar archivos y carpetas untracked.
