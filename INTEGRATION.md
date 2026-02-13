# Integración del Sistema Matrix Shader

## Archivos Modificados y Agregados

### Nuevos Archivos
1. `Quake/shaders/matrix.vert` - Vertex shader Matrix
2. `Quake/shaders/matrix.frag` - Fragment shader Matrix con digital rain
3. `Quake/matrix_shader.h` - Header del sistema de shaders
4. `Quake/matrix_shader.c` - Implementación del sistema de shaders

### Archivos a Modificar

#### 1. `Quake/Makefile` (y variantes .w32, .w64, .darwin)

Agregar `matrix_shader.o` a la lista de objetos:

```makefile
# Buscar la sección de OBJS y agregar:
OBJS += matrix_shader.o
```

#### 2. `Quake/gl_vidsdl.c`

En la función `GL_Init()`, agregar después de la inicialización de OpenGL:

```c
// Inicializar sistema Matrix Shader
MatrixShader_Init();
```

En la función `VID_Shutdown()`, agregar:

```c
// Cerrar sistema Matrix Shader
MatrixShader_Shutdown();
```

#### 3. `Quake/gl_rmain.c`

En el include section al inicio:

```c
#include "matrix_shader.h"
```

En la función `R_RenderView()`, después de configurar viewport:

```c
// Actualizar shader Matrix
MatrixShader_Update(host_frametime);

// Si el shader está habilitado, activarlo
if (r_matrix.value > 0 && matrixshader.initialized) {
    MatrixShader_Enable();
    MatrixShader_SetUniforms();
}
```

Al final de `R_RenderView()`, antes de return:

```c
// Desactivar shader Matrix
if (r_matrix.value > 0 && matrixshader.initialized) {
    MatrixShader_Disable();
}
```

#### 4. `Quake/gl_screen.c`

Para post-procesamiento de pantalla completa, en `SCR_UpdateScreen()`:

```c
// Aplicar efecto Matrix como post-proceso
if (r_matrix.value > 0 && matrixshader.initialized) {
    // El shader ya está aplicado durante el render
}
```

## Variables de Consola Agregadas

- `r_matrix` (0/1) - Activa/desactiva el efecto Matrix
- `r_matrix_intensity` (0.0-1.0) - Intensidad del efecto Matrix

## Uso

```
// En consola de Quake:
r_matrix 1                  // Activar efecto Matrix
r_matrix_intensity 0.8      // Ajustar intensidad al 80%
r_matrix 0                  // Desactivar efecto
```

## Notas de Implementación

1. El sistema usa OpenGL 2.0+ con GLSL 120
2. Los shaders se cargan desde archivos si existen, sino usa versiones embebidas
3. El efecto se aplica como overlay sobre el renderizado normal
4. Compatible con el pipeline de renderizado existente de QuakeSpasm

## Próximos Pasos

1. Integrar fuentes Matrix auténticas
2. Mejorar algoritmo de digital rain
3. Agregar efectos de bloom y glow
4. Optimizar performance
