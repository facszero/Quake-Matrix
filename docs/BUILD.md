# Guía de Compilación - Quake-Matrix

## Prerrequisitos

### Windows

1. **MinGW-w64**
   - Descargar desde: https://winlibs.com/ o https://www.mingw-w64.org/
   - Versión recomendada: GCC 11.0 o superior
   - Arquitectura: x86_64 (64-bit)
   - Añadir al PATH: `C:\mingw64\bin`

2. **SDL2 Development Libraries**
   - Descargar desde: https://www.libsdl.org/download-2.0.php
   - Necesitas: SDL2-devel-2.x.x-mingw.tar.gz
   - Extraer en: `engine/Windows/SDL2/`

3. **Codecs de Audio (Opcional)**
   - libmad (MP3)
   - libogg, libvorbis (OGG)
   - Descargar desde: https://sourceforge.net/projects/quakespasm/files/Support%20Files/
   - Extraer DLLs en: `engine/Windows/codecs/`

4. **Make**
   - Incluido con MinGW-w64
   - Verificar: `mingw32-make --version`

### Linux

```bash
# Debian/Ubuntu
sudo apt-get install build-essential libsdl2-dev libvorbis-dev libmad0-dev

# Fedora
sudo dnf install gcc make SDL2-devel libvorbis-devel libmad-devel

# Arch
sudo pacman -S base-devel sdl2 libvorbis libmad
```

### macOS

```bash
# Usando Homebrew
brew install sdl2 libvorbis mad

# Usando MacPorts
sudo port install libsdl2 libvorbis libmad
```

## Estructura de Archivos Necesarios

```
Quake-Matrix/
├── engine/
│   ├── Makefile           # Linux/Unix
│   ├── Makefile.w64       # Windows 64-bit
│   ├── *.c, *.h          # Código fuente
│   └── Windows/          # Dependencias Windows
│       ├── SDL2/
│       └── codecs/
├── src/
│   ├── gl_matrix.c       # Sistema Matrix
│   ├── gl_matrix.h
│   └── gl_matrix_atlas.c
└── assets/
    └── shaders/
        ├── matrix_vertex.glsl
        ├── matrix_fragment.glsl
        └── matrix_postprocess.glsl
```

## Proceso de Compilación

### Windows (64-bit)

#### Paso 1: Preparar Dependencias

```bash
cd Quake-Matrix/engine/Windows

# Si no tienes las bibliotecas, descargarlas:
# 1. SDL2-devel-2.x.x-mingw.tar.gz
# 2. Extraer en SDL2/

# Verificar estructura:
# Windows/
#   SDL2/
#     include/SDL2/
#     lib/
#     x86_64-w64-mingw32/
```

#### Paso 2: Compilar

```bash
cd Quake-Matrix/engine

# Compilación estándar (SDL2)
mingw32-make -f Makefile.w64 USE_SDL2=1

# Compilación con soporte MP3
mingw32-make -f Makefile.w64 USE_SDL2=1 USE_CODEC_MP3=1

# Compilación con todos los codecs
mingw32-make -f Makefile.w64 USE_SDL2=1 USE_CODEC_WAVE=1 USE_CODEC_FLAC=1 USE_CODEC_MP3=1 USE_CODEC_VORBIS=1 USE_CODEC_OPUS=1

# Compilación debug
mingw32-make -f Makefile.w64 USE_SDL2=1 DEBUG=1

# Limpiar
mingw32-make -f Makefile.w64 clean
```

#### Paso 3: Ejecutar

```bash
# El ejecutable se genera como: quakespasm.exe

# Crear estructura de directorios
mkdir id1

# Copiar PAK files de Quake original a id1/
# (pak0.pak y pak1.pak desde tu instalación de Quake)

# Copiar DLLs necesarias al directorio del ejecutable:
cp Windows/SDL2/x86_64-w64-mingw32/bin/SDL2.dll .
# Y las DLLs de codecs si las usas

# Ejecutar
./quakespasm.exe
```

### Linux

```bash
cd Quake-Matrix/engine

# Compilación básica
make

# Con SDL2
make USE_SDL2=1

# Con soporte para directorios de usuario
make DO_USERDIRS=1

# Debug
make DEBUG=1

# Limpiar
make clean

# Instalar (opcional)
sudo make install
# O copiar manualmente:
cp quakespasm /usr/local/games/quake/
```

### macOS

```bash
cd Quake-Matrix/engine

# Compilación
make USE_SDL2=1

# O usando el script de cross-compilación
./build_cross_osx-sdl2.sh
```

## Integración del Código Matrix

Para integrar el código Matrix personalizado en el motor:

### Paso 1: Copiar archivos fuente

```bash
# Copiar archivos Matrix al directorio engine
cp src/gl_matrix.c engine/
cp src/gl_matrix.h engine/
cp src/gl_matrix_atlas.c engine/
```

### Paso 2: Modificar Makefile

Editar `engine/Makefile.w64` (o el Makefile correspondiente):

```makefile
# Añadir a la lista de objetos:
OBJS += gl_matrix.o gl_matrix_atlas.o

# El sistema de build automáticamente compilará los nuevos archivos
```

### Paso 3: Integrar en el motor

Los siguientes archivos del motor necesitan modificarse:

1. **engine/gl_rmain.c** - Loop principal de renderizado
   ```c
   #include "gl_matrix.h"
   
   // En R_Init():
   Matrix_Init();
   
   // En R_Shutdown():
   Matrix_Shutdown();
   
   // En R_RenderView():
   Matrix_BeginFrame();
   // ... renderizado normal ...
   Matrix_EndFrame();
   ```

2. **engine/glquake.h** - Headers principales
   ```c
   #include "gl_matrix.h"
   ```

## Opciones de Compilación

### Variables de Make

```bash
USE_SDL2=1          # Usar SDL2 en lugar de SDL1.2
DEBUG=1             # Compilación debug con símbolos
DO_USERDIRS=1       # Soporte para directorios de usuario
USE_CODEC_WAVE=1    # Soporte WAV
USE_CODEC_MP3=1     # Soporte MP3
USE_CODEC_VORBIS=1  # Soporte OGG Vorbis
USE_CODEC_OPUS=1    # Soporte Opus
USE_CODEC_FLAC=1    # Soporte FLAC
```

### Ejemplo Compilación Completa

```bash
mingw32-make -f Makefile.w64 \
  USE_SDL2=1 \
  USE_CODEC_WAVE=1 \
  USE_CODEC_MP3=1 \
  USE_CODEC_VORBIS=1 \
  USE_CODEC_OPUS=1 \
  -j4
```

## Solución de Problemas

### Error: "SDL.h: No such file or directory"

**Solución**: Verificar que SDL2 está instalado correctamente
```bash
# Windows: Verificar engine/Windows/SDL2/include/SDL2/SDL.h existe
# Linux: sudo apt-get install libsdl2-dev
```

### Error: "undefined reference to `glCreateShader`"

**Solución**: Faltan bibliotecas de OpenGL
```bash
# Windows: Debería estar en -lopengl32 (incluido automáticamente)
# Linux: sudo apt-get install libgl1-mesa-dev
```

### Error: Compilación muy lenta

**Solución**: Usar compilación paralela
```bash
mingw32-make -f Makefile.w64 -j4  # 4 hilos paralelos
```

### Advertencias sobre funciones deprecadas

**Solución**: Normal en código legacy, puedes ignorarlas o compilar con:
```bash
make CFLAGS="-Wno-deprecated-declarations"
```

## Verificación Post-Compilación

```bash
# Verificar que el ejecutable se creó
ls -lh quakespasm.exe  # Windows
ls -lh quakespasm      # Linux/macOS

# Verificar dependencias (Windows)
ldd quakespasm.exe     # MinGW
objdump -p quakespasm.exe | grep DLL

# Verificar dependencias (Linux)
ldd quakespasm

# Probar ejecución básica
./quakespasm.exe -basedir . -window -width 800 -height 600
```

## Optimizaciones de Compilación

### Release Optimizado

```bash
# Windows
mingw32-make -f Makefile.w64 USE_SDL2=1 CFLAGS="-O3 -march=native"

# Linux
make USE_SDL2=1 CFLAGS="-O3 -march=native -flto"
```

### Tamaño Mínimo

```bash
make USE_SDL2=1 CFLAGS="-Os -s"
strip quakespasm  # Eliminar símbolos debug
```

## Próximos Pasos

1. Compilar el motor base sin modificaciones
2. Verificar que funciona con Quake original
3. Integrar código Matrix
4. Compilar versión Matrix
5. Probar shaders y efectos
6. Optimizar rendimiento

## Referencias

- [QuakeSpasm Build Documentation](https://github.com/sezero/quakespasm)
- [MinGW-w64 Documentation](https://www.mingw-w64.org/)
- [SDL2 Documentation](https://wiki.libsdl.org/)

---

**Última actualización**: 13 de Febrero 2026  
**Mantenedor**: Fernando Cañete (@facszero)
