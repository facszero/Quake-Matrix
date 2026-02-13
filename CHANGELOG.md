# Changelog - Quake-Matrix

Todos los cambios notables en este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/lang/es/).

## [Sin Publicar]

### Por Hacer
- Integración completa de shaders en el motor
- Compilación de versión funcional
- Sistema de instalador Windows
- Generación de atlas de caracteres desde fuente Matrix Code NFI
- Efectos de post-procesamiento (bloom/glow)
- Optimización de rendimiento
- Testing con diferentes mapas de Quake

## [0.1.0] - 2026-02-13

### Fase 1: Configuración Base del Proyecto

#### Añadido
- Estructura completa de directorios del proyecto
- Integración del código fuente de QuakeSpasm como base
- Sistema de shaders GLSL para efecto Matrix:
  - `matrix_vertex.glsl` - Vertex shader principal con transformaciones
  - `matrix_fragment.glsl` - Fragment shader con efecto Digital Rain completo
  - `matrix_postprocess.glsl` - Post-procesamiento para bloom y glow
- Implementación del sistema Matrix en C:
  - `gl_matrix.h` - Definiciones y API del sistema
  - `gl_matrix.c` - Implementación principal con carga de shaders
  - `gl_matrix_atlas.c` - Generación de atlas de caracteres
- CVars para configuración del efecto Matrix:
  - `matrix_enable` - Activar/desactivar modo Matrix
  - `matrix_rainspeed` - Velocidad de caída de caracteres
  - `matrix_density` - Densidad de caracteres en pantalla
  - `matrix_color_r/g/b` - Color RGB personalizable
  - `matrix_glow` - Intensidad del resplandor
  - `matrix_trail_length` - Longitud de rastros
- Documentación completa:
  - `README.md` - Descripción general y roadmap
  - `docs/TECHNICAL.md` - Documentación técnica detallada
  - `docs/CONFIG_GUIDE.md` - Guía de configuración para usuarios
  - `docs/BUILD.md` - Instrucciones completas de compilación
- Configuración de Git:
  - `.gitignore` - Exclusiones apropiadas para el proyecto
  - Configuración de autor y commits

#### Técnico
- Sistema de generación procedural de atlas de caracteres (512x512, 16x16 grid)
- Shader con PRNG para variación de caracteres
- Sistema de trails con fade-out temporal
- Efecto de "cabeza brillante" en streams de caracteres
- Integración con CVars de Quake para configuración persistente
- Soporte para renderizado normal y Matrix mediante toggle

#### Documentado
- Arquitectura completa del sistema
- Pipeline de renderizado Matrix vs Quake original
- Explicación detallada de shaders GLSL
- Configuraciones preestablecidas para diferentes estilos
- Instrucciones de compilación multiplataforma
- Solución de problemas comunes

### Estado del Proyecto

**Fase Actual**: Fase 1 ✅ COMPLETADA

**Próxima Fase**: Fase 2 - Integración de shaders en el motor
- Modificar gl_rmain.c para llamar funciones Matrix
- Implementar paso de matrices al shader
- Integrar en el loop de renderizado
- Compilar primera versión funcional

### Métricas

- **Archivos creados**: 181
- **Líneas de código**: ~87,000+
- **Shaders GLSL**: 3 (vertex, fragment, postprocess)
- **Archivos de código C**: 3 (header + 2 implementaciones)
- **Documentación**: 5 archivos (README + 4 guías)
- **CVars implementados**: 8

### Créditos del Lanzamiento

- **Desarrollador Principal**: Fernando Cañete (@facszero)
- **Motor Base**: QuakeSpasm Team
- **Motor Original**: id Software (John Carmack y equipo)
- **Inspiración**: The Matrix (Wachowski Sisters)

---

## Formato de Versiones

- **MAJOR**: Cambios incompatibles con versiones anteriores
- **MINOR**: Nueva funcionalidad compatible con versiones anteriores
- **PATCH**: Correcciones de bugs compatibles con versiones anteriores

## Categorías de Cambios

- **Añadido**: para nuevas características
- **Cambiado**: para cambios en funcionalidad existente
- **Deprecado**: para características que se eliminarán pronto
- **Eliminado**: para características eliminadas
- **Corregido**: para corrección de bugs
- **Seguridad**: en caso de vulnerabilidades
- **Técnico**: detalles de implementación técnica
- **Documentado**: cambios en documentación

---

**Proyecto**: Quake-Matrix  
**Repositorio**: https://github.com/facszero/Quake-Matrix  
**Licencia**: GPL-2.0
