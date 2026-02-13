# Guía de Compilación - Quake-Matrix

Esta guía te ayudará a compilar Quake-Matrix en diferentes plataformas.

## 📋 Requisitos Previos

### Linux (Ubuntu/Debian)

```bash
sudo apt-get update
sudo apt-get install build-essential git
sudo apt-get install libsdl2-dev libgl1-mesa-dev
```

### Windows (MinGW-w64)

1. Instalar [MSYS2](https://www.msys2.org/)
2. En terminal MSYS2:

```bash
pacman -S mingw-w64-x86_64-gcc
pacman -S mingw-w64-x86_64-SDL2
pacman -S make
```

### macOS

```bash
brew install sdl2
```

## 🔨 Compilación

### Linux

```bash
cd Quake-Matrix/Quake
make
```

El ejecutable se generará como `quakespasm` en el directorio `Quake/`.

### Windows (MinGW-w64)

```bash
cd Quake-Matrix/Quake
make -f Makefile.w64
```

El ejecutable se generará como `quakespasm.exe`.

### Windows (Cross-compile desde Linux)

```bash
cd Quake-Matrix/Quake
./build_cross_win64-sdl2.sh
```

### macOS

```bash
cd Quake-Matrix/Quake
make -f Makefile.darwin
```

## 🎮 Ejecución

### Requisitos de Datos del Juego

Quake-Matrix necesita los archivos de datos del Quake original:
- `PAK0.PAK`
- `PAK1.PAK` (opcional, para contenido completo)

Coloca estos archivos en una carpeta `id1/` junto al ejecutable.

### Estructura de Directorios

```
quakespasm(.exe)
shaders/
  ├── matrix.vert
  └── matrix.frag
id1/
  ├── PAK0.PAK
  └── PAK1.PAK
```

### Ejecutar

```bash
# Linux/macOS
./quakespasm

# Windows
quakespasm.exe
```

## ⚙️ Opciones de Compilación

### Debug Build

```bash
make DEBUG=1
```

### SDL2 (Recomendado)

```bash
make USE_SDL2=1
```

### Optimizaciones Adicionales

Edita el `Makefile` y modifica las flags de CFLAGS:

```makefile
CFLAGS += -O3 -march=native
```

## 🔧 Resolución de Problemas

### Error: SDL2 no encontrado

**Linux:**
```bash
sudo apt-get install libsdl2-dev
```

**Windows (MSYS2):**
```bash
pacman -S mingw-w64-x86_64-SDL2
```

### Error: OpenGL headers no encontrados

**Linux:**
```bash
sudo apt-get install mesa-common-dev libgl1-mesa-dev
```

### Shaders no cargan

Los shaders se cargarán desde `shaders/matrix.vert` y `shaders/matrix.frag` si existen. Si no, se usarán versiones embebidas simplificadas. Asegúrate de que la carpeta `shaders/` esté junto al ejecutable.

## 📦 Crear Distribución

### Linux

```bash
# Compilar
make USE_SDL2=1
strip quakespasm

# Crear paquete
mkdir -p quake-matrix-linux
cp quakespasm quake-matrix-linux/
cp -r shaders quake-matrix-linux/
cp README.md quake-matrix-linux/
tar -czf quake-matrix-linux.tar.gz quake-matrix-linux/
```

### Windows

```bash
# Compilar
make -f Makefile.w64 USE_SDL2=1

# Copiar DLLs necesarias de SDL2
cp /mingw64/bin/SDL2.dll .

# Crear paquete
mkdir quake-matrix-windows
cp quakespasm.exe quake-matrix-windows/
cp SDL2.dll quake-matrix-windows/
cp -r shaders quake-matrix-windows/
cp README.md quake-matrix-windows/
zip -r quake-matrix-windows.zip quake-matrix-windows/
```

## 🚀 Compilación Avanzada

### Profile-Guided Optimization (PGO)

```bash
# 1. Compilar con instrumentación
make CFLAGS="-fprofile-generate"

# 2. Ejecutar el juego y jugar varios niveles
./quakespasm

# 3. Recompilar con optimizaciones basadas en perfil
make clean
make CFLAGS="-fprofile-use"
```

### Link-Time Optimization (LTO)

```bash
make CFLAGS="-flto" LDFLAGS="-flto"
```

## 📝 Notas

- La compilación tarda aproximadamente 1-2 minutos en hardware moderno
- El ejecutable resultante pesa aproximadamente 2-3 MB
- Para desarrollo, usa `DEBUG=1` para mejores mensajes de error
- Para distribución, usa optimizaciones y `strip` para reducir tamaño

## 🆘 Soporte

Si encuentras problemas durante la compilación, abre un issue en:
https://github.com/facszero/Quake-Matrix/issues
