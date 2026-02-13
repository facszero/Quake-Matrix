#!/bin/bash
################################################################################
# Quake-Matrix - Verificador de Configuración
# Verifica que todo esté listo para ejecutar
################################################################################

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        QUAKE-MATRIX - VERIFICADOR DE SISTEMA              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

READY=1

echo -e "${YELLOW}Verificando configuración...${NC}"
echo ""

# 1. Verificar estructura de directorios
echo -n "📁 Directorio Quake/... "
if [ -d "Quake" ]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗ FALTA${NC}"
    READY=0
fi

echo -n "📁 Directorio id1/... "
if [ -d "id1" ]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗ FALTA${NC}"
    READY=0
fi

echo -n "📁 Directorio assets/shaders/... "
if [ -d "assets/shaders" ]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗ FALTA${NC}"
    READY=0
fi

echo ""

# 2. Verificar archivos críticos
echo -n "📄 pak0.pak... "
if [ -f "id1/pak0.pak" ]; then
    SIZE=$(stat -f%z "id1/pak0.pak" 2>/dev/null || stat -c%s "id1/pak0.pak" 2>/dev/null)
    SIZE_MB=$((SIZE / 1024 / 1024))
    echo -e "${GREEN}✓ (${SIZE_MB}MB)${NC}"
else
    echo -e "${RED}✗ FALTA${NC}"
    READY=0
fi

echo -n "📄 matrix_vertex.glsl... "
if [ -f "assets/shaders/matrix_vertex.glsl" ]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗ FALTA${NC}"
    READY=0
fi

echo -n "📄 matrix_fragment.glsl... "
if [ -f "assets/shaders/matrix_fragment.glsl" ]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗ FALTA${NC}"
    READY=0
fi

echo -n "📄 matrix_postprocess.glsl... "
if [ -f "assets/shaders/matrix_postprocess.glsl" ]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗ FALTA${NC}"
    READY=0
fi

echo ""

# 3. Verificar binario
echo -n "⚙️  quakespasm binario... "
if [ -f "Quake/quakespasm" ]; then
    if [ -x "Quake/quakespasm" ]; then
        SIZE=$(stat -f%z "Quake/quakespasm" 2>/dev/null || stat -c%s "Quake/quakespasm" 2>/dev/null)
        SIZE_MB=$(echo "scale=1; $SIZE / 1024 / 1024" | bc)
        echo -e "${GREEN}✓ (${SIZE_MB}MB)${NC}"
    else
        echo -e "${YELLOW}⚠ Existe pero no es ejecutable${NC}"
        chmod +x Quake/quakespasm
        echo -e "  ${GREEN}✓ Permisos corregidos${NC}"
    fi
else
    echo -e "${YELLOW}⚠ NO COMPILADO${NC}"
    echo -e "  ${YELLOW}Ejecuta: ./build_linux.sh${NC}"
    READY=0
fi

echo ""

# 4. Verificar símbolos si el binario existe
if [ -f "Quake/quakespasm" ]; then
    echo -e "${YELLOW}Verificando integración Matrix...${NC}"
    
    echo -n "🔍 Matrix_Init... "
    if nm Quake/quakespasm 2>/dev/null | grep -q "Matrix_Init"; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗ NO ENCONTRADO${NC}"
        READY=0
    fi
    
    echo -n "🔍 Matrix_BeginFrame... "
    if nm Quake/quakespasm 2>/dev/null | grep -q "Matrix_BeginFrame"; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗ NO ENCONTRADO${NC}"
        READY=0
    fi
    
    echo -n "🔍 Matrix_EndFrame... "
    if nm Quake/quakespasm 2>/dev/null | grep -q "Matrix_EndFrame"; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗ NO ENCONTRADO${NC}"
        READY=0
    fi
    
    echo ""
fi

# 5. Verificar dependencias del sistema
echo -e "${YELLOW}Verificando dependencias del sistema...${NC}"

echo -n "📦 libSDL... "
if ldconfig -p 2>/dev/null | grep -q "libSDL" || [ -f "/usr/lib/libSDL.so" ] || [ -f "/usr/lib/x86_64-linux-gnu/libSDL-1.2.so.0" ]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗ NO INSTALADA${NC}"
    echo -e "  ${YELLOW}Instala: sudo apt-get install libsdl1.2debian${NC}"
    READY=0
fi

echo -n "📦 OpenGL... "
if ldconfig -p 2>/dev/null | grep -q "libGL.so" || [ -f "/usr/lib/x86_64-linux-gnu/libGL.so" ]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${YELLOW}⚠ No verificable${NC}"
fi

echo ""

# 6. Información del sistema
echo -e "${YELLOW}Información del sistema...${NC}"

echo -n "🖥️  GPU: "
GPU=$(lspci 2>/dev/null | grep -i "vga\|3d\|display" | head -1 | cut -d: -f3 | xargs)
if [ -n "$GPU" ]; then
    echo "$GPU"
else
    echo "No detectada"
fi

echo -n "💾 Espacio libre: "
FREE=$(df -h . | tail -1 | awk '{print $4}')
echo "$FREE"

echo ""

# Resumen final
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    RESUMEN                                 ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

if [ $READY -eq 1 ]; then
    echo -e "${GREEN}✓✓✓ SISTEMA LISTO PARA EJECUTAR ✓✓✓${NC}"
    echo ""
    echo -e "${YELLOW}Próximo paso:${NC}"
    echo "  ./run.sh"
    echo ""
    echo -e "${YELLOW}O manualmente:${NC}"
    echo "  cd Quake"
    echo "  ./quakespasm"
    echo ""
    exit 0
else
    echo -e "${RED}✗✗✗ SISTEMA NO LISTO ✗✗✗${NC}"
    echo ""
    echo -e "${YELLOW}Acciones requeridas:${NC}"
    
    if [ ! -f "Quake/quakespasm" ]; then
        echo "  1. Compilar: ./build_linux.sh"
    fi
    
    if [ ! -f "id1/pak0.pak" ]; then
        echo "  2. Copiar pak0.pak a id1/"
    fi
    
    if ! ldconfig -p 2>/dev/null | grep -q "libSDL"; then
        echo "  3. Instalar SDL: sudo apt-get install libsdl1.2debian"
    fi
    
    echo ""
    exit 1
fi
