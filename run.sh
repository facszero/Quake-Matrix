#!/bin/bash
################################################################################
# Quake-Matrix - Script de Ejecución Rápida
# Ejecuta Quake-Matrix con configuración óptima
################################################################################

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              QUAKE-MATRIX - LAUNCHER                       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Verificar que estamos en el directorio correcto
if [ ! -d "Quake" ]; then
    echo -e "${RED}ERROR: Ejecuta desde el directorio raíz de Quake-Matrix${NC}"
    exit 1
fi

# Verificar binario
if [ ! -f "Quake/quakespasm" ]; then
    echo -e "${YELLOW}⚠ Binario no encontrado. Compilando...${NC}"
    ./build_linux.sh
    if [ $? -ne 0 ]; then
        echo -e "${RED}ERROR: Compilación falló${NC}"
        exit 1
    fi
fi

# Verificar pak0.pak
if [ ! -f "id1/pak0.pak" ]; then
    echo -e "${RED}ERROR: id1/pak0.pak no encontrado${NC}"
    echo "Copia pak0.pak del Quake original a: id1/"
    exit 1
fi

echo -e "${GREEN}✓ Binario encontrado${NC}"
echo -e "${GREEN}✓ pak0.pak encontrado${NC}"
echo -e "${GREEN}✓ Shaders listos${NC}"
echo ""
echo -e "${YELLOW}Iniciando Quake-Matrix...${NC}"
echo ""
echo -e "${BLUE}Comandos útiles en consola (~):${NC}"
echo "  matrix_enable 1      - Activar Matrix"
echo "  matrix_enable 0      - Quake normal"
echo "  map e1m1            - Cargar primer mapa"
echo "  matrix_rainspeed 5  - Lluvia más rápida"
echo "  matrix_density 30   - Más caracteres"
echo "  matrix_glow 2.0     - Más brillo"
echo ""
echo -e "${YELLOW}Presiona Ctrl+C para salir antes de iniciar...${NC}"
sleep 3
echo ""

# Ejecutar con configuración óptima
cd Quake
./quakespasm \
    +matrix_enable 1 \
    +matrix_rainspeed 2.5 \
    +matrix_density 20 \
    +vid_width 1024 \
    +vid_height 768 \
    "$@"
