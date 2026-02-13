# Quake-Matrix

**Una reinterpretación del motor Quake original en el universo de The Matrix**

## Descripción

Quake-Matrix es una modificación del motor Quake que transforma la experiencia de juego transportándote al universo visual de The Matrix. El jugador verá el mundo a través de los ojos de Neo, con todo el entorno renderizado usando el icónico estilo de "código verde cayendo" (Matrix Digital Rain) de las películas.

## Características

- ✅ Motor basado en QuakeSpasm (GPL)
- 🎨 Renderizado visual estilo Matrix con caracteres verdes cayendo
- 🔤 Fuentes auténticas de The Matrix (Matrix Code NFI)
- 🎮 Compatibilidad con mapas y mods de Quake original
- 💚 Shader personalizado para efecto "Digital Rain"
- 🖥️ Soporte nativo para Windows

## Fases de Desarrollo

### Fase 1: Base del Proyecto ✅
- Configuración del repositorio Git
- Estructura de directorios
- Integración del código fuente de QuakeSpasm
- Documentación inicial

### Fase 2: Sistema de Renderizado Matrix (En Desarrollo)
- Implementación del shader de "Digital Rain"
- Integración de fuentes Matrix
- Sistema de partículas con caracteres japoneses/katakana
- Efectos de resplandor verde

### Fase 3: Interfaz de Usuario
- HUD rediseñado estilo Matrix
- Menús con efectos de código verde
- Consola personalizada

### Fase 4: Optimización y Pulido
- Optimización de rendimiento
- Ajustes de color y brillo
- Efectos de post-procesamiento

### Fase 5: Empaquetado y Distribución
- Instalador para Windows
- Documentación de usuario
- Archivos de configuración predeterminados

## Requisitos

### Para Compilar
- MinGW-w64 (Windows)
- SDL2
- OpenGL 2.0+
- Git

### Para Ejecutar
- Windows 7 o superior
- Tarjeta gráfica con soporte OpenGL 2.0+
- Archivos PAK de Quake original (id1/pak0.pak, id1/pak1.pak)

## Compilación

```bash
cd engine
make -f Makefile.w32
```

## Instalación

1. Descargar el instalador desde Releases
2. Ejecutar el instalador
3. Copiar los archivos PAK de Quake original a la carpeta `id1/`
4. ¡Ejecutar y disfrutar del mundo Matrix!

## Licencia

Este proyecto está basado en QuakeSpasm y mantiene la licencia GPL v2.

- **Motor Quake**: GPL v2 (id Software)
- **QuakeSpasm**: GPL v2
- **Código personalizado**: GPL v2
- **Assets visuales Matrix**: Solo uso educativo/personal

## Créditos

- **Desarrollador**: Fernando Cañete (facszero)
- **Motor Base**: QuakeSpasm team
- **Motor Original**: id Software (John Carmack y equipo)
- **Inspiración Visual**: The Matrix (Wachowski Sisters)
- **Fuente**: Matrix Code NFI (Norfok Incredible Font Design)

## Contacto

- GitHub: [@facszero](https://github.com/facszero)
- Email: facs.zero@gmail.com

## Estado del Proyecto

🚧 **En Desarrollo Activo** 🚧

Actualmente en Fase 1 - Configuración del proyecto base completada.

## Capturas de Pantalla

_Próximamente - Cuando tengamos el renderizado Matrix funcionando_

---

**Nota**: Este es un proyecto educativo y de entretenimiento. Se requieren los archivos originales de Quake para jugar.
