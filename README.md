# Quake-Matrix

**Motor Quake en el Universo Matrix**

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
- [ ] Compilación inicial

### Fase 2: Shader Matrix (En Progreso)
- [ ] Implementar shader de digital rain
- [ ] Integrar con pipeline de renderizado 3D
- [ ] Ajuste de parámetros visuales

### Fase 3: Fuentes y Efectos
- [ ] Integrar fuentes Matrix auténticas
- [ ] Implementar bloom y glow
- [ ] Ajuste de colores fosforescentes

### Fase 4: Build y Distribución
- [ ] Compilación para Windows
- [ ] Creación de instalador
- [ ] Documentación de usuario

## 🔧 Requisitos de Compilación

### Windows
- MinGW-w64 o Visual Studio 2019+
- SDL2
- OpenGL

### Linux
- GCC
- SDL2-dev
- Mesa OpenGL

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
