# Documentación Técnica - Quake-Matrix

## Arquitectura del Proyecto

### Estructura de Directorios

```
Quake-Matrix/
├── engine/              # Código fuente del motor (basado en QuakeSpasm)
│   ├── gl_*.c/h        # Renderizado OpenGL
│   ├── r_*.c/h         # Sistema de rendering
│   ├── snd_*.c/h       # Sistema de sonido
│   ├── vid_*.c/h       # Sistema de video
│   └── ...
├── src/                # Código personalizado para Matrix
│   ├── matrix_shader.c # Shader del efecto Digital Rain
│   ├── matrix_render.c # Sistema de renderizado Matrix
│   └── matrix_fonts.c  # Gestión de fuentes Matrix
├── assets/             # Recursos visuales y fuentes
│   ├── fonts/          # Fuentes Matrix Code NFI
│   ├── shaders/        # Shaders GLSL
│   └── textures/       # Texturas para efectos
├── docs/               # Documentación
├── build/              # Archivos de compilación
└── installer/          # Scripts para crear instalador

```

## Modificaciones Clave al Motor

### 1. Sistema de Renderizado Matrix

El corazón de Quake-Matrix es su sistema de renderizado personalizado que transforma toda la geometría 3D en el característico "código verde cayendo" de The Matrix.

#### Componentes Principales:

**a) Matrix Shader System**
- Shader GLSL personalizado para generar el efecto Digital Rain
- Post-procesamiento de toda la escena
- Gestión de buffers de caracteres

**b) Character Pool**
- Pool de caracteres japoneses (katakana, hiragana)
- Caracteres latinos en espejo
- Números y símbolos
- Generación procedural de streams de caracteres

**c) Color System**
- Paleta de verdes Matrix (#00FF00 primario)
- Gradientes de brillo para profundidad
- Efectos de resplandor (bloom)
- Trails de caracteres con fade-out

### 2. Integración con QuakeSpasm

QuakeSpasm proporciona una base sólida:
- Renderizado OpenGL moderno
- Soporte SDL2 para input/audio/video
- Compatibilidad con mods de Quake
- 64-bit correctness

Nuestras modificaciones se centran en:
- `gl_rmain.c` - Loop principal de renderizado
- `gl_rmisc.c` - Funciones auxiliares de render
- `gl_screen.c` - Gestión de pantalla y HUD

### 3. Pipeline de Renderizado

```
Quake Original:           Quake-Matrix:
BSP Geometry    →         BSP Geometry
    ↓                         ↓
Lighting        →         Matrix Character Generator
    ↓                         ↓
Texturing       →         Digital Rain Shader
    ↓                         ↓
Effects         →         Green Glow Post-Processing
    ↓                         ↓
Screen Output   →         Screen Output
```

## Shaders GLSL

### Vertex Shader (matrix_vertex.glsl)

```glsl
#version 120

attribute vec3 in_position;
attribute vec2 in_texcoord;
attribute vec3 in_normal;

varying vec2 v_texcoord;
varying vec3 v_normal;
varying vec3 v_position;

uniform mat4 u_modelViewProjection;
uniform mat4 u_modelView;
uniform mat4 u_normalMatrix;

void main() {
    gl_Position = u_modelViewProjection * vec4(in_position, 1.0);
    v_texcoord = in_texcoord;
    v_normal = normalize((u_normalMatrix * vec4(in_normal, 0.0)).xyz);
    v_position = (u_modelView * vec4(in_position, 1.0)).xyz;
}
```

### Fragment Shader (matrix_fragment.glsl)

```glsl
#version 120

varying vec2 v_texcoord;
varying vec3 v_normal;
varying vec3 v_position;

uniform sampler2D u_charTexture;
uniform float u_time;
uniform vec3 u_matrixColor;
uniform float u_rainSpeed;
uniform float u_charDensity;

// Generador de números pseudo-aleatorios
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

// Selector de carácter basado en posición y tiempo
vec2 getCharUV(vec2 uv, float time) {
    // Grid de caracteres (16x16 = 256 caracteres)
    vec2 grid = vec2(16.0, 16.0);
    
    // Posición en el grid
    vec2 gridPos = floor(uv * u_charDensity);
    
    // Velocidad de caída basada en posición
    float fallSpeed = random(gridPos) * u_rainSpeed;
    
    // Offset animado
    float offset = fract(time * fallSpeed + random(gridPos));
    
    // Selección de carácter
    float charIndex = floor(random(gridPos + offset) * 256.0);
    vec2 charUV = vec2(mod(charIndex, 16.0), floor(charIndex / 16.0)) / grid;
    
    // UV dentro del carácter
    vec2 localUV = fract(uv * u_charDensity) / grid;
    
    return charUV + localUV;
}

void main() {
    vec2 charUV = getCharUV(v_texcoord, u_time);
    
    // Samplear el carácter
    float charMask = texture2D(u_charTexture, charUV).r;
    
    // Cálculo de brillo basado en profundidad y normal
    float depth = length(v_position);
    float brightness = 1.0 - smoothstep(0.0, 50.0, depth);
    
    // Efecto de trailing (caracteres más antiguos más oscuros)
    float trail = fract(u_time * u_rainSpeed);
    float fade = smoothstep(0.0, 0.3, trail) * (1.0 - smoothstep(0.7, 1.0, trail));
    
    // Color final
    vec3 color = u_matrixColor * charMask * brightness * fade;
    
    // Brillo extra para caracteres "frescos"
    if (trail > 0.8) {
        color += vec3(0.3, 0.5, 0.3) * charMask;
    }
    
    gl_FragColor = vec4(color, charMask);
}
```

## Fuentes Matrix

### Integración de Matrix Code NFI

La fuente Matrix Code NFI se integra como una textura atlas de caracteres:

1. **Conversión de fuente a bitmap**
   - Renderizar todos los caracteres a una textura 4096x4096
   - 16x16 grid = 256 caracteres únicos
   - Incluir caracteres katakana, números, símbolos

2. **Gestión de atlas**
   - Carga en tiempo de inicio
   - Binding como texture unit dedicada
   - Mip-mapping para diferentes distancias

3. **Selección de caracteres**
   - PRNG para variedad
   - Bias hacia ciertos caracteres más "Matrix"
   - Animación de cambio de caracteres

## Sistema de Partículas Matrix

Para efectos especiales (disparos, explosiones, etc.):

```c
typedef struct matrix_particle_s {
    vec3_t position;
    vec3_t velocity;
    float lifetime;
    float fade;
    char character;
    vec3_t color;
} matrix_particle_t;

void Matrix_UpdateParticles(float frametime);
void Matrix_RenderParticles(void);
void Matrix_EmitParticles(vec3_t origin, int count);
```

## Configuración y CVars

Nuevos comandos de consola para personalización:

```
matrix_enable [0|1]           - Activar/desactivar modo Matrix
matrix_rainspeed [0.1-10.0]   - Velocidad de caída de caracteres
matrix_density [1.0-50.0]     - Densidad de caracteres
matrix_color_r [0.0-1.0]      - Componente roja del color
matrix_color_g [0.0-1.0]      - Componente verde del color
matrix_color_b [0.0-1.0]      - Componente azul del color
matrix_glow [0.0-2.0]         - Intensidad del resplandor
matrix_trail_length [0.0-1.0] - Longitud de los trails
```

## Compilación para Windows

### Requisitos
- MinGW-w64 (gcc 8.1.0 o superior)
- SDL2 development libraries
- OpenGL headers
- Make

### Proceso

```bash
# Descargar dependencias
cd engine/Windows
./get_libs.sh

# Compilar
cd ..
make -f Makefile.w32 USE_SDL2=1

# El ejecutable se genera como quakespasm.exe
```

### Dependencias Runtime
- SDL2.dll
- OpenGL32.dll (sistema)
- libmad-0.dll o libmpg123-0.dll (música MP3)
- libogg-0.dll, libvorbis-0.dll, libvorbisfile-3.dll (música OGG)

## Próximos Pasos de Implementación

1. **Implementar shader básico** - Renderizar toda la escena en verde
2. **Añadir atlas de caracteres** - Integrar la fuente Matrix
3. **Implementar Digital Rain** - Shader con caracteres cayendo
4. **Optimizar rendimiento** - Asegurar 60+ FPS
5. **Post-procesamiento** - Bloom y efectos de resplandor
6. **UI personalizada** - Menús y HUD estilo Matrix

## Referencias

- [QuakeSpasm Documentation](https://quakespasm.sourceforge.net/)
- [OpenGL Shader Language](https://www.khronos.org/opengl/wiki/OpenGL_Shading_Language)
- [Matrix Digital Rain](https://en.wikipedia.org/wiki/Matrix_digital_rain)
- [FitzQuake Protocol](https://fitzquake.sourceforge.net/fitzquake_protocol.txt)

---

**Versión**: 0.1.0 (Fase 1)  
**Fecha**: 13 de Febrero 2026  
**Autor**: Fernando Cañete
