#!/bin/bash
################################################################################
# Quake-Matrix - Script de Compilación para Linux
# Autor: Fernando Cañete
################################################################################

set -e  # Salir si hay error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         QUAKE-MATRIX - COMPILACIÓN LINUX                  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Verificar que estamos en el directorio correcto
if [ ! -d "Quake" ]; then
    echo -e "${RED}ERROR: Ejecuta este script desde el directorio raíz de Quake-Matrix${NC}"
    exit 1
fi

# Verificar dependencias
echo -e "${YELLOW}[1/6] Verificando dependencias...${NC}"

command -v gcc >/dev/null 2>&1 || { 
    echo -e "${RED}ERROR: gcc no está instalado${NC}"
    echo "Instala con: sudo apt-get install build-essential"
    exit 1
}

command -v sdl-config >/dev/null 2>&1 || command -v sdl2-config >/dev/null 2>&1 || {
    echo -e "${RED}ERROR: SDL development libraries no están instaladas${NC}"
    echo "Instala con: sudo apt-get install libsdl1.2-dev"
    echo "O para SDL2: sudo apt-get install libsdl2-dev"
    exit 1
}

echo -e "${GREEN}✓ Dependencias OK${NC}"

# Limpiar compilación anterior
echo -e "${YELLOW}[2/6] Limpiando compilación anterior...${NC}"
cd Quake
make clean 2>/dev/null || true
echo -e "${GREEN}✓ Limpieza completada${NC}"

# Verificar archivos críticos
echo -e "${YELLOW}[3/6] Verificando archivos críticos...${NC}"
MISSING=0

if [ ! -f "../src/gl_matrix.c" ]; then
    echo -e "${RED}✗ Falta: src/gl_matrix.c${NC}"
    MISSING=1
fi

if [ ! -f "../src/gl_matrix.h" ]; then
    echo -e "${RED}✗ Falta: src/gl_matrix.h${NC}"
    MISSING=1
fi

if [ ! -f "../src/gl_matrix_atlas.c" ]; then
    echo -e "${RED}✗ Falta: src/gl_matrix_atlas.c${NC}"
    MISSING=1
fi

if [ ! -f "../assets/shaders/matrix_vertex.glsl" ]; then
    echo -e "${RED}✗ Falta: assets/shaders/matrix_vertex.glsl${NC}"
    MISSING=1
fi

if [ ! -f "../assets/shaders/matrix_fragment.glsl" ]; then
    echo -e "${RED}✗ Falta: assets/shaders/matrix_fragment.glsl${NC}"
    MISSING=1
fi

if [ ! -f "../assets/shaders/matrix_postprocess.glsl" ]; then
    echo -e "${RED}✗ Falta: assets/shaders/matrix_postprocess.glsl${NC}"
    MISSING=1
fi

if [ $MISSING -eq 1 ]; then
    echo -e "${RED}ERROR: Archivos críticos faltantes${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Todos los archivos presentes${NC}"

# Compilar
echo -e "${YELLOW}[4/6] Compilando Quake-Matrix...${NC}"
echo ""

if make -j$(nproc) 2>&1 | tee /tmp/quakematrix_build.log; then
    echo ""
    echo -e "${GREEN}✓ Compilación exitosa${NC}"
else
    echo ""
    echo -e "${RED}✗ Error de compilación${NC}"
    echo -e "${YELLOW}Ver log completo en: /tmp/quakematrix_build.log${NC}"
    exit 1
fi

# Verificar binario
echo -e "${YELLOW}[5/6] Verificando binario...${NC}"

if [ ! -f "quakespasm" ]; then
    echo -e "${RED}ERROR: El binario quakespasm no fue creado${NC}"
    exit 1
fi

BINSIZE=$(stat -f%z "quakespasm" 2>/dev/null || stat -c%s "quakespasm" 2>/dev/null)
echo -e "${GREEN}✓ Binario creado: quakespasm ($(numfmt --to=iec-i --suffix=B $BINSIZE))${NC}"

# Verificar símbolos Matrix
echo -e "${YELLOW}[6/6] Verificando símbolos Matrix...${NC}"

if nm quakespasm | grep -q "Matrix_Init"; then
    echo -e "${GREEN}✓ Matrix_Init encontrado${NC}"
else
    echo -e "${RED}✗ Matrix_Init NO encontrado${NC}"
fi

if nm quakespasm | grep -q "Matrix_BeginFrame"; then
    echo -e "${GREEN}✓ Matrix_BeginFrame encontrado${NC}"
else
    echo -e "${RED}✗ Matrix_BeginFrame NO encontrado${NC}"
fi

if nm quakespasm | grep -q "Matrix_EndFrame"; then
    echo -e "${GREEN}✓ Matrix_EndFrame encontrado${NC}"
else
    echo -e "${RED}✗ Matrix_EndFrame NO encontrado${NC}"
fi

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              COMPILACIÓN COMPLETADA                        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Binario creado en:${NC} Quake/quakespasm"
echo ""
echo -e "${YELLOW}Próximos pasos:${NC}"
echo "1. Copiar archivos PAK de Quake a: ../id1/"
echo "   cp /path/to/quake/pak0.pak ../id1/"
echo ""
echo "2. Ejecutar desde el directorio raíz:"
echo "   cd .."
echo "   ./Quake/quakespasm"
echo ""
echo "3. En la consola (~), probar:"
echo "   matrix_enable 1"
echo "   map e1m1"
echo ""
echo -e "${GREEN}¡Buena suerte!${NC}"
