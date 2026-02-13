# Guía de Instalación - Quake-Matrix

## 📦 Descargar Archivos de Quake

Quake-Matrix require los archivos de datos del Quake original. Puedes obtenerlos de:

1. **Steam**: Compra Quake en Steam
2. **GOG**: Compra Quake en GOG.com  
3. **Shareware**: Descarga la versión shareware gratuita (solo Episodio 1)

### Ubicación de Archivos

**Steam (Windows):**
```
C:\Program Files (x86)\Steam\steamapps\common\Quake\id1\
```

**Steam (Linux):**
```
~/.steam/steam/steamapps/common/Quake/id1/
```

**GOG:**
```
<GOG Install Dir>\Quake\id1\
```

## 🎮 Instalación Completa

### Paso 1: Compilar Quake-Matrix

Sigue las instrucciones en [BUILD.md](BUILD.md) para compilar el motor.

### Paso 2: Configurar Directorio del Juego

Crea la siguiente estructura de directorios:

```
QuakeMatrix/
├── quakespasm(.exe)          # Ejecutable compilado
├── SDL2.dll                   # Solo Windows
├── shaders/
│   ├── matrix.vert
│   └── matrix.frag
└── id1/
    ├── PAK0.PAK              # Requerido
    ├── PAK1.PAK              # Opcional (contenido completo)
    └── config.cfg            # Se generará automáticamente
```

### Paso 3: Copiar Archivos de Quake

**Desde Steam/GOG:**

```bash
# Linux/macOS
cp /ruta/a/steam/Quake/id1/PAK*.PAK QuakeMatrix/id1/

# Windows (PowerShell)
Copy-Item "C:\Program Files (x86)\Steam\steamapps\common\Quake\id1\PAK*.PAK" QuakeMatrix\id1\
```

### Paso 4: Copiar Shaders

```bash
# Linux/macOS
cp -r Quake-Matrix/Quake/shaders QuakeMatrix/

# Windows
xcopy /E /I Quake-Matrix\Quake\shaders QuakeMatrix\shaders
```

### Paso 5: Ejecutar

```bash
# Linux/macOS
cd QuakeMatrix
./quakespasm

# Windows
cd QuakeMatrix
quakespasm.exe
```

## ⚙️ Configuración Inicial

Al iniciar por primera vez, abre la consola con `~` y configura:

```
// Configuración recomendada para Matrix
r_matrix_overlay 1
r_matrix_overlay_intensity 0.7
r_matrix_overlay_speed 1.0
r_matrix_overlay_density 0.6

// Guardar configuración
writeconfig matrix.cfg
```

Para cargar automáticamente al iniciar:

```
// En consola
exec matrix.cfg
```

O crea un archivo `autoexec.cfg` en `id1/` con tu configuración preferida.

## 🎨 Temas Matrix

### Modo Neo (Matrix Completo)
```
r_matrix_overlay 1
r_matrix_overlay_intensity 1.0
r_matrix_overlay_speed 1.2
r_matrix_overlay_density 0.8
```

### Modo Operador (Matrix Sutil)
```
r_matrix_overlay 1
r_matrix_overlay_intensity 0.5
r_matrix_overlay_speed 0.8
r_matrix_overlay_density 0.4
```

### Modo Cypher (Lluvia Intensa)
```
r_matrix_overlay 1
r_matrix_overlay_intensity 0.9
r_matrix_overlay_speed 2.0
r_matrix_overlay_density 0.9
```

## 🕹️ Controles

Los controles son los mismos que Quake original:

- **WASD** o **Flechas**: Movimiento
- **Mouse**: Mirar
- **Espacio**: Saltar
- **Ctrl**: Disparar
- **1-8**: Cambiar armas
- **~**: Console (para ajustar Matrix)
- **ESC**: Menú

## 🔧 Resolución de Problemas

### El efecto Matrix no aparece

1. Verifica en consola:
   ```
   r_matrix_overlay
   ```
   Debe mostrar "1"

2. Aumenta la intensidad:
   ```
   r_matrix_overlay_intensity 1.0
   ```

3. Verifica que los shaders estén en `shaders/`

### Rendimiento bajo

```
// Reduce densidad y velocidad
r_matrix_overlay_density 0.4
r_matrix_overlay_speed 0.5

// O desactiva temporalmente
r_matrix_overlay 0
```

### Pantalla negra al iniciar

Verifica que PAK0.PAK esté en id1/ y que tengas permisos de lectura.

## 📝 Archivos Opcionales

### Música
Quake-Matrix soporta música en formato OGG/MP3. Coloca archivos de música como:

```
id1/music/track02.ogg
id1/music/track03.ogg
...
```

### Mods
Quake-Matrix es compatible con mods de Quake. Colócalos en sus propios directorios:

```
QuakeMatrix/
├── id1/           # Quake original
├── hipnotic/      # Mission Pack 1
├── rogue/         # Mission Pack 2
└── mod_name/      # Tu mod
```

Ejecuta con: `./quakespasm -game mod_name`

## 🌐 Multijugador

Quake-Matrix funciona con servidores de Quake estándar:

```
// Conectar a servidor
connect direccion.servidor.com

// O desde consola
./quakespasm +connect direccion.servidor.com
```

El efecto Matrix es local y no afecta a otros jugadores.

## 💾 Savegames

Los savegames son compatibles con QuakeSpasm vanilla. Puedes:

1. Guardar en Quake-Matrix
2. Cargar en QuakeSpasm original
3. Y viceversa

Ubicación: `id1/save/`

## 🎬 Demo Recording

Para grabar demos con el efecto Matrix:

```
// Iniciar grabación
record nombre_demo

// Detener
stop

// Reproducir
playdemo nombre_demo
```

Demos se guardan en `id1/` como `.dem`

---

¡Disfruta de Quake en Matrix!
