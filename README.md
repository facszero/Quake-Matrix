# Quake-Matrix

**Motor Quake en el Universo Matrix**

```
 ██████╗ ██╗   ██╗ █████╗ ██╗  ██╗███████╗    ███╗   ███╗ █████╗ ████████╗██████╗ ██╗██╗  ██╗
██╔═══██╗██║   ██║██╔══██╗██║ ██╔╝██╔════╝    ████╗ ████║██╔══██╗╚══██╔══╝██╔══██╗██║╚██╗██╔╝
██║   ██║██║   ██║███████║█████╔╝ █████╗█████╗██╔████╔██║███████║   ██║   ██████╔╝██║ ╚███╔╝ 
██║▄▄ ██║██║   ██║██╔══██║██╔═██╗ ██╔══╝╚════╝██║╚██╔╝██║██╔══██║   ██║   ██╔══██╗██║ ██╔██╗ 
╚██████╔╝╚██████╔╝██║  ██║██║  ██╗███████╗    ██║ ╚═╝ ██║██║  ██║   ██║   ██║  ██║██║██╔╝ ██╗
 ╚══▀▀═╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝    ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝
```

Proyecto que implementa una versión modificada del motor Quake original donde toda la visualización del mundo 3D se presenta con el efecto de "digital rain" (lluvia de código verde) característico de la película The Matrix.

## 🎯 Objetivo

Transformar la experiencia visual de Quake para que el jugador vea el mundo a través de los ojos de Neo, con el código Matrix cayendo sobre toda la geometría, texturas y elementos del juego.

## 🛠️ Basado en

Este proyecto está basado en [QuakeSpasm](https://github.com/sezero/quakespasm), un motor Quake moderno y multiplataforma derivado de FitzQuake.

## ✨ Características Planeadas

- **Visualización Matrix**: Todo el mundo 3D renderizado con el efecto de código verde cayendo
- **Fuentes Auténticas**: Uso de las fuentes Matrix originales (katakana invertido + caracteres Chicago)
- **Efectos Visuales**: Bloom, glow y tone-mapping verde fosforescente
- **Modo Neo**: Opción para alternar entre vista normal y vista Matrix
- **Instalador Windows**: Ejecutable e instalador listo para usar

## 📋 Fases de Desarrollo

### Fase 1: Configuración Base ✅
- [x] Clonar QuakeSpasm
- [x] Configurar repositorio
- [x] Sistema de shaders GLSL (preparado para futuro)
- [x] Integración en motor base

### Fase 2: Overlay Matrix ✅  
- [x] Implementar sistema de overlay compatible con fixed pipeline
- [x] Generación procedural de textura de glyphs
- [x] Animación de digital rain por columnas
- [x] Integración completa en pipeline de renderizado
- [x] Variables de consola para control

### Fase 3: Mejoras Visuales (En Progreso)
- [ ] Mejorar glyphs con fuentes Matrix auténticas
- [ ] Implementar bloom y glow mejorado
- [ ] Ajuste fino de colores y efectos
- [ ] Optimización de rendimiento

### Fase 4: Build y Distribución
- [ ] Compilación para Windows
- [ ] Creación de instalador
- [ ] Documentación de usuario

## 📚 Documentación

- **[Guía de Compilación](BUILD.md)** - Instrucciones detalladas para compilar en diferentes plataformas
- **[Guía de Instalación](INSTALL.md)** - Cómo instalar y configurar el juego completo
- **[Integración Técnica](INTEGRATION.md)** - Detalles de implementación para desarrolladores
- **[Configuración de Ejemplo](matrix_example.cfg)** - Archivo de configuración con ajustes recomendados

## 🚀 Inicio Rápido

```bash
# 1. Clonar repositorio
git clone https://github.com/facszero/Quake-Matrix.git
cd Quake-Matrix/Quake

# 2. Compilar (requiere SDL2 y OpenGL)
make USE_SDL2=1

# 3. Copiar archivos de datos de Quake a id1/
# 4. Ejecutar
./quakespasm
```

Ver [INSTALL.md](INSTALL.md) para instrucciones completas.

### Windows
- MinGW-w64 o Visual Studio 2019+
- SDL2
- OpenGL

### Linux
- GCC
- SDL2-dev
- Mesa OpenGL

## 🎮 Uso

Una vez compilado, puedes controlar el efecto Matrix desde la consola de Quake (~):

```
// Activar/desactivar efecto Matrix
r_matrix_overlay 1           // Activar
r_matrix_overlay 0           // Desactivar

// Ajustar intensidad (0.0 a 1.0)
r_matrix_overlay_intensity 0.7

// Velocidad de caída del código
r_matrix_overlay_speed 1.0

// Densidad de columnas activas (0.0 a 1.0)
r_matrix_overlay_density 0.6
```

## 📄 Licencia

Este proyecto hereda la licencia GPL v2 de QuakeSpasm y del código fuente original de Quake.

## 👤 Autor

Fernando Cañete (facszero)
- GitHub: [@facszero](https://github.com/facszero)
- Email: facs.zero@gmail.com

## 🙏 Créditos

- id Software - Quake original
- QuakeSpasm team - Motor base
- Simon Whiteley - Diseño de fuentes Matrix originales
- Wachowski Brothers - The Matrix

---

*"Welcome to the real world, Neo."*
