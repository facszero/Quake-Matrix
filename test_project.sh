#!/bin/bash
################################################################################
# Quake-Matrix - Script de Testing Automatizado
# Autor: Fernando Cañete
################################################################################

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         QUAKE-MATRIX - TESTING AUTOMATIZADO               ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

TESTS_PASSED=0
TESTS_FAILED=0

# Función para test
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo -n "Testing: $test_name... "
    
    if eval "$test_command" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
}

echo -e "${YELLOW}=== PRUEBAS DE ESTRUCTURA ===${NC}"
echo ""

run_test "Directorio raíz existe" "[ -d '/home/claude/Quake-Matrix' ]"
run_test "Directorio Quake/ existe" "[ -d 'Quake' ]"
run_test "Directorio src/ existe" "[ -d 'src' ]"
run_test "Directorio assets/ existe" "[ -d 'assets' ]"
run_test "Directorio engine/ existe" "[ -d 'engine' ]"

echo ""
echo -e "${YELLOW}=== PRUEBAS DE ARCHIVOS FUENTE ===${NC}"
echo ""

run_test "gl_matrix.c existe" "[ -f 'src/gl_matrix.c' ]"
run_test "gl_matrix.h existe" "[ -f 'src/gl_matrix.h' ]"
run_test "gl_matrix_atlas.c existe" "[ -f 'src/gl_matrix_atlas.c' ]"
run_test "gl_rmain.c modificado" "grep -q 'Matrix_BeginFrame' engine/gl_rmain.c"
run_test "gl_vidsdl.c modificado" "grep -q 'Matrix_Init' engine/gl_vidsdl.c"

echo ""
echo -e "${YELLOW}=== PRUEBAS DE SHADERS ===${NC}"
echo ""

run_test "matrix_vertex.glsl existe" "[ -f 'assets/shaders/matrix_vertex.glsl' ]"
run_test "matrix_fragment.glsl existe" "[ -f 'assets/shaders/matrix_fragment.glsl' ]"
run_test "matrix_postprocess.glsl existe" "[ -f 'assets/shaders/matrix_postprocess.glsl' ]"

# Verificar que shaders no están vacíos
if [ -f "assets/shaders/matrix_vertex.glsl" ]; then
    LINES=$(wc -l < assets/shaders/matrix_vertex.glsl)
    run_test "matrix_vertex.glsl no vacío (>10 líneas)" "[ $LINES -gt 10 ]"
fi

if [ -f "assets/shaders/matrix_fragment.glsl" ]; then
    LINES=$(wc -l < assets/shaders/matrix_fragment.glsl)
    run_test "matrix_fragment.glsl no vacío (>50 líneas)" "[ $LINES -gt 50 ]"
fi

echo ""
echo -e "${YELLOW}=== PRUEBAS DE MAKEFILE ===${NC}"
echo ""

run_test "Makefile existe" "[ -f 'Quake/Makefile' ]"
run_test "Makefile incluye gl_matrix.o" "grep -q 'gl_matrix.o' Quake/Makefile"
run_test "Makefile incluye gl_matrix_atlas.o" "grep -q 'gl_matrix_atlas.o' Quake/Makefile"

echo ""
echo -e "${YELLOW}=== PRUEBAS DE CÓDIGO ===${NC}"
echo ""

# Verificar que las funciones existen
run_test "Matrix_Init declarada" "grep -q 'void Matrix_Init' src/gl_matrix.c"
run_test "Matrix_BeginFrame declarada" "grep -q 'void Matrix_BeginFrame' src/gl_matrix.c"
run_test "Matrix_EndFrame declarada" "grep -q 'void Matrix_EndFrame' src/gl_matrix.c"
run_test "Matrix_SetMatrices declarada" "grep -q 'void Matrix_SetMatrices' src/gl_matrix.c"

# Verificar CVars
run_test "CVar matrix_enable" "grep -q 'matrix_enable' src/gl_matrix.c"
run_test "CVar matrix_rainspeed" "grep -q 'matrix_rainspeed' src/gl_matrix.c"
run_test "CVar matrix_density" "grep -q 'matrix_density' src/gl_matrix.c"

echo ""
echo -e "${YELLOW}=== PRUEBAS DE INTEGRACIÓN ===${NC}"
echo ""

run_test "gl_rmain.c incluye gl_matrix.h" "grep -q '#include.*gl_matrix.h' engine/gl_rmain.c"
run_test "gl_vidsdl.c incluye gl_matrix.h" "grep -q '#include.*gl_matrix.h' engine/gl_vidsdl.c"
run_test "R_RenderView llama Matrix_BeginFrame" "grep -A 50 'R_RenderView' engine/gl_rmain.c | grep -q 'Matrix_BeginFrame'"
run_test "R_RenderView llama Matrix_EndFrame" "grep -A 100 'R_RenderView' engine/gl_rmain.c | grep -q 'Matrix_EndFrame'"
run_test "GL_Init llama Matrix_Init" "grep -A 50 'GL_Init' engine/gl_vidsdl.c | grep -q 'Matrix_Init'"
run_test "VID_Shutdown llama Matrix_Shutdown" "grep -A 20 'VID_Shutdown' engine/gl_vidsdl.c | grep -q 'Matrix_Shutdown'"

echo ""
echo -e "${YELLOW}=== PRUEBAS DE DOCUMENTACIÓN ===${NC}"
echo ""

run_test "README.md existe" "[ -f 'README.md' ]"
run_test "LICENSE existe" "[ -f 'LICENSE' ]"
run_test "docs/TECHNICAL.md existe" "[ -f 'docs/TECHNICAL.md' ]"
run_test "docs/BUILD.md existe" "[ -f 'docs/BUILD.md' ]"
run_test "docs/CONFIG_GUIDE.md existe" "[ -f 'docs/CONFIG_GUIDE.md' ]"

echo ""
echo -e "${YELLOW}=== PRUEBAS DE GIT ===${NC}"
echo ""

run_test "Repositorio Git inicializado" "[ -d '.git' ]"
run_test "Tiene commits" "git log --oneline | wc -l | awk '{exit !($1 > 0)}'"
run_test ".gitignore existe" "[ -f '.gitignore' ]"

# Verificar binario si existe
if [ -f "Quake/quakespasm" ]; then
    echo ""
    echo -e "${YELLOW}=== PRUEBAS DE BINARIO ===${NC}"
    echo ""
    
    run_test "Binario quakespasm existe" "[ -f 'Quake/quakespasm' ]"
    run_test "Binario es ejecutable" "[ -x 'Quake/quakespasm' ]"
    run_test "Binario contiene Matrix_Init" "nm Quake/quakespasm | grep -q 'Matrix_Init'"
    run_test "Binario contiene Matrix_BeginFrame" "nm Quake/quakespasm | grep -q 'Matrix_BeginFrame'"
    run_test "Binario contiene Matrix_EndFrame" "nm Quake/quakespasm | grep -q 'Matrix_EndFrame'"
fi

# Resumen
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                  RESUMEN DE TESTS                          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Tests pasados:${NC} $TESTS_PASSED"
echo -e "${RED}Tests fallados:${NC} $TESTS_FAILED"
echo ""

TOTAL=$((TESTS_PASSED + TESTS_FAILED))
PERCENTAGE=$((TESTS_PASSED * 100 / TOTAL))

echo -e "Porcentaje de éxito: ${PERCENTAGE}%"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ Todos los tests pasaron!${NC}"
    echo -e "${GREEN}El proyecto está listo para compilar.${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠ Algunos tests fallaron.${NC}"
    echo -e "${YELLOW}Revisa los errores antes de compilar.${NC}"
    exit 1
fi
