# QUAKE-MATRIX - INICIO RÁPIDO

## 🚀 EJECUTAR EN 3 PASOS

### 1️⃣ Compilar (solo primera vez)
```bash
./build_linux.sh
```

### 2️⃣ Ejecutar
```bash
./run.sh
```

### 3️⃣ Jugar
- Presiona `~` para abrir consola
- Escribe: `map e1m1`
- ¡Disfruta de Quake en Matrix!

---

## 🎮 COMANDOS DE CONSOLA

### Activar/Desactivar Matrix
```
matrix_enable 1    # Activar
matrix_enable 0    # Desactivar (Quake normal)
```

### Ajustar Efecto Matrix
```
matrix_rainspeed 5.0    # Lluvia más rápida (default: 2.5)
matrix_density 30       # Más caracteres (default: 20)
matrix_glow 2.0         # Más brillo (default: 1.2)
matrix_trail_length 0.8 # Trails más largos (default: 0.6)
```

### Cambiar Color
```
matrix_color_r 0.0      # Rojo (default: 0.0)
matrix_color_g 1.0      # Verde (default: 1.0)  
matrix_color_b 0.2      # Azul (default: 0.2)
```

### Cargar Mapas
```
map e1m1    # Slipgate Complex
map e1m2    # Castle of the Damned
map e1m3    # The Necropolis
map e1m4    # The Grisly Grotto
map start   # Mapa de inicio
```

---

## 🎨 PRESETS RECOMENDADOS

### Matrix Clásico (película)
```
matrix_enable 1
matrix_rainspeed 2.5
matrix_density 20
matrix_color_r 0.0
matrix_color_g 1.0
matrix_color_b 0.2
matrix_glow 1.2
```

### Matrix Intenso
```
matrix_rainspeed 5.0
matrix_density 35
matrix_glow 2.0
```

### Matrix Sutil
```
matrix_rainspeed 1.5
matrix_density 10
matrix_glow 0.8
```

### Modo Neo (verde brillante)
```
matrix_color_r 0.2
matrix_color_g 1.0
matrix_color_b 0.3
matrix_glow 2.5
```

---

## 🔧 SOLUCIÓN DE PROBLEMAS

### Pantalla negra
1. Verifica que `assets/shaders/*.glsl` existan
2. Ejecuta desde directorio raíz (no desde `Quake/`)
3. Intenta: `matrix_enable 0`

### Performance bajo
```
matrix_density 10
matrix_rainspeed 1.5
```

### Error de compilación
```bash
make clean
./build_linux.sh
```

---

## 📁 ESTRUCTURA DE ARCHIVOS

```
Quake-Matrix/
├── Quake/
│   └── quakespasm         # Binario (después de compilar)
├── id1/
│   └── pak0.pak          # ✓ YA ESTÁ AQUÍ
├── assets/
│   └── shaders/          # Shaders GLSL Matrix
├── src/                  # Código fuente Matrix
├── build_linux.sh        # Script de compilación
└── run.sh               # Script de ejecución
```

---

## ⌨️ CONTROLES

- **W/A/S/D** - Movimiento
- **Mouse** - Mirar
- **Espacio** - Saltar
- **Ctrl** - Disparar
- **~** - Consola
- **Esc** - Menú
- **1-8** - Cambiar arma

---

## 🎯 SIGUIENTE PASO

¡Ejecuta `./run.sh` y disfruta de Quake en el universo Matrix!

---

## 🔗 LINKS

- GitHub: https://github.com/facszero/Quake-Matrix
- Issues: https://github.com/facszero/Quake-Matrix/issues
- Wiki: https://github.com/facszero/Quake-Matrix/wiki

---

## 📝 NOTAS

- Este es un mod del motor QuakeSpasm
- Requiere archivos originales de Quake (pak0.pak)
- GPL-2.0 License
- © 2026 Fernando Cañete
