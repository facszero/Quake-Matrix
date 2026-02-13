# Instrucciones para Subir Quake-Matrix a GitHub

El proyecto está listo para ser subido a GitHub. Tienes 8 commits locales que contienen todo el trabajo realizado.

## Opción 1: Usando GitHub CLI (Recomendado)

Si tienes `gh` instalado:

```bash
# Autenticarse con GitHub
gh auth login

# Crear el repositorio
gh repo create Quake-Matrix --public --source=. --remote=origin --push
```

## Opción 2: Usando Git con Token Personal

1. **Crear un Personal Access Token en GitHub:**
   - Ve a: https://github.com/settings/tokens
   - Click en "Generate new token" → "Generate new token (classic)"
   - Nombre: "Quake-Matrix Upload"
   - Selecciona el scope: `repo` (Full control of private repositories)
   - Click "Generate token"
   - **COPIA EL TOKEN** (solo se muestra una vez)

2. **Crear el repositorio en GitHub:**
   - Ve a: https://github.com/new
   - Repository name: `Quake-Matrix`
   - Description: "Quake engine mod with Matrix digital rain effects"
   - Public
   - **NO inicialices con README, .gitignore o license** (ya los tienes localmente)
   - Click "Create repository"

3. **Subir el código:**

```bash
cd /home/claude/Quake-Matrix

# El remote ya está configurado correctamente
git remote -v

# Hacer push (te pedirá usuario y password)
# Usuario: facszero
# Password: [PEGA TU TOKEN AQUÍ, NO TU PASSWORD DE GITHUB]
git push -u origin master
```

## Opción 3: Usando SSH (Más seguro a largo plazo)

1. **Generar clave SSH** (si no tienes una):
```bash
ssh-keygen -t ed25519 -C "facs.zero@gmail.com"
cat ~/.ssh/id_ed25519.pub
```

2. **Agregar la clave a GitHub:**
   - Ve a: https://github.com/settings/ssh/new
   - Pega el contenido de `~/.ssh/id_ed25519.pub`
   - Click "Add SSH key"

3. **Cambiar remote a SSH:**
```bash
cd /home/claude/Quake-Matrix
git remote set-url origin git@github.com:facszero/Quake-Matrix.git
git push -u origin master
```

## Verificación

Después del push exitoso, verifica:
- https://github.com/facszero/Quake-Matrix debe mostrar tu código
- Deberías ver 8 commits en el historial
- Archivos principales: README.md, BUILD.md, INSTALL.md, matrix_overlay.c/h

## Siguiente Paso

Una vez subido a GitHub, el siguiente paso es crear el instalador para Windows.
