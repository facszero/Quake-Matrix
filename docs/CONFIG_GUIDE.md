# Guía de Configuración - Quake-Matrix

## Configuración Inicial

Al ejecutar Quake-Matrix por primera vez, el juego creará un archivo `config.cfg` con la configuración predeterminada.

## Comandos de Consola Matrix

Presiona **`** (tecla tilde) o **Shift+Escape** para abrir la consola.

### Comandos Principales

```
matrix_enable [0|1]
```
Activa o desactiva el modo Matrix.
- `0` = Desactivado (Quake normal)
- `1` = Activado (modo Matrix)
- Por defecto: `1`

```
matrix_rainspeed [0.1 - 10.0]
```
Controla la velocidad de caída de los caracteres.
- Valores bajos = Caída lenta, más atmosférico
- Valores altos = Caída rápida, más caótico
- Por defecto: `2.5`

```
matrix_density [1.0 - 50.0]
```
Densidad de caracteres en pantalla.
- Valores bajos = Menos caracteres, más rendimiento
- Valores altos = Más caracteres, más detalle
- Por defecto: `20.0`

```
matrix_color_r [0.0 - 1.0]
matrix_color_g [0.0 - 1.0]
matrix_color_b [0.0 - 1.0]
```
Componentes RGB del color principal.
- Para verde Matrix clásico: R=0.0, G=1.0, B=0.0
- Por defecto: R=0.0, G=1.0, B=0.2

```
matrix_glow [0.0 - 2.0]
```
Intensidad del efecto de resplandor.
- `0.0` = Sin resplandor
- `2.0` = Resplandor máximo
- Por defecto: `1.2`

```
matrix_trail_length [0.0 - 1.0]
```
Longitud de los rastros de caracteres.
- `0.0` = Sin rastro
- `1.0` = Rastros largos
- Por defecto: `0.6`

## Configuraciones Preestablecidas

### Matrix Clásico (Como en la película)
```
matrix_enable 1
matrix_rainspeed 2.5
matrix_density 20
matrix_color_r 0
matrix_color_g 1
matrix_color_b 0.2
matrix_glow 1.2
matrix_trail_length 0.6
```

### Matrix Intenso (Más denso y rápido)
```
matrix_enable 1
matrix_rainspeed 5.0
matrix_density 35
matrix_color_r 0
matrix_color_g 1
matrix_color_b 0.3
matrix_glow 1.5
matrix_trail_length 0.8
```

### Matrix Sutil (Menos agresivo)
```
matrix_enable 1
matrix_rainspeed 1.5
matrix_density 12
matrix_color_r 0
matrix_color_g 0.8
matrix_color_b 0.15
matrix_glow 0.8
matrix_trail_length 0.4
```

### Modo Neo (Verde brillante)
```
matrix_enable 1
matrix_rainspeed 3.0
matrix_density 25
matrix_color_r 0.1
matrix_color_g 1.0
matrix_color_b 0.1
matrix_glow 2.0
matrix_trail_length 0.7
```

## Comandos Generales de Quake

### Video
```
vid_width [ancho]
vid_height [alto]
```
Establece la resolución de pantalla.
Ejemplo: `vid_width 1920; vid_height 1080; vid_restart`

```
vid_fullscreen [0|1]
```
Pantalla completa o ventana.

```
vid_vsync [0|1]
```
Sincronización vertical (elimina tearing).

### Rendimiento
```
r_drawworld [0|1]
```
Dibuja el mundo (útil para depuración).

```
r_drawentities [0|1]
```
Dibuja entidades.

```
r_particles [0|1]
```
Activa/desactiva partículas.

```
fps_max [número]
```
Limita FPS máximo (0 = sin límite).

### Audio
```
volume [0.0 - 1.0]
```
Volumen general.

```
bgmvolume [0.0 - 1.0]
```
Volumen de música de fondo.

## Archivo de Configuración Personalizado

Puedes crear un archivo `autoexec.cfg` en la carpeta `id1/` que se ejecutará automáticamente al inicio.

Ejemplo de `autoexec.cfg`:
```
// Configuración Matrix personalizada
matrix_enable 1
matrix_rainspeed 3.0
matrix_density 22
matrix_glow 1.5

// Configuración de video
vid_width 1920
vid_height 1080
vid_fullscreen 1
vid_vsync 1

// Rendimiento
fps_max 120

// Audio
volume 0.7
bgmvolume 0.5

echo "Configuración Matrix cargada - Bienvenido al mundo real, Neo"
```

## Controles por Defecto

- **W/A/S/D** - Movimiento
- **Mouse** - Mirar
- **Click Izquierdo** - Disparar
- **Espacio** - Saltar
- **1-8** - Seleccionar arma
- **Tab** - Marcador
- **Escape** - Menú
- **F12** - Screenshot
- **`** - Consola

## Solución de Problemas

### Rendimiento Bajo
Si el juego va lento:
```
matrix_density 10
matrix_glow 0.5
r_particles 0
```

### El efecto Matrix no se ve
1. Verificar que OpenGL 2.0+ está disponible
2. Verificar que los shaders están en `assets/shaders/`
3. Verificar que el atlas de caracteres está cargado
4. Intentar: `matrix_enable 0; matrix_enable 1`

### Pantalla muy oscura
```
gamma 0.9
matrix_glow 1.8
```

### Pantalla muy brillante
```
gamma 0.7
matrix_glow 0.8
```

## Tips Avanzados

### Grabar Demos
```
record [nombre]
```
Graba una demo.

```
stop
```
Detiene la grabación.

```
playdemo [nombre]
```
Reproduce una demo.

### Screenshots
```
screenshot
```
Toma un screenshot (guardado en el directorio del juego).

### Benchmark
```
timedemo [nombre_demo]
```
Ejecuta una demo y muestra estadísticas de rendimiento.

---

**¿Necesitas ayuda?**
- GitHub: https://github.com/facszero/Quake-Matrix
- Email: facs.zero@gmail.com
