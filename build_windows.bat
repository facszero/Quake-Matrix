@echo off
REM ============================================================================
REM Quake-Matrix - Script de Compilación para Windows
REM Autor: Fernando Cañete
REM ============================================================================

setlocal enabledelayedexpansion

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║        QUAKE-MATRIX - COMPILACIÓN WINDOWS                 ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

REM Verificar que estamos en el directorio correcto
if not exist "Quake" (
    echo [ERROR] Ejecuta este script desde el directorio raíz de Quake-Matrix
    exit /b 1
)

REM Verificar MinGW
echo [1/6] Verificando MinGW-w64...
where gcc >nul 2>&1
if errorlevel 1 (
    echo [ERROR] gcc no está instalado o no está en PATH
    echo Instala MinGW-w64 desde: https://www.mingw-w64.org/
    exit /b 1
)

gcc --version | findstr "mingw"
if errorlevel 1 (
    echo [ADVERTENCIA] gcc encontrado pero no es MinGW
)

echo [OK] MinGW encontrado
echo.

REM Limpiar compilación anterior
echo [2/6] Limpiando compilación anterior...
cd Quake
mingw32-make -f Makefile.w64 clean >nul 2>&1
echo [OK] Limpieza completada
echo.

REM Verificar archivos críticos
echo [3/6] Verificando archivos críticos...
set MISSING=0

if not exist "..\src\gl_matrix.c" (
    echo [FALTA] src\gl_matrix.c
    set MISSING=1
)

if not exist "..\src\gl_matrix.h" (
    echo [FALTA] src\gl_matrix.h
    set MISSING=1
)

if not exist "..\src\gl_matrix_atlas.c" (
    echo [FALTA] src\gl_matrix_atlas.c
    set MISSING=1
)

if not exist "..\assets\shaders\matrix_vertex.glsl" (
    echo [FALTA] assets\shaders\matrix_vertex.glsl
    set MISSING=1
)

if not exist "..\assets\shaders\matrix_fragment.glsl" (
    echo [FALTA] assets\shaders\matrix_fragment.glsl
    set MISSING=1
)

if not exist "..\assets\shaders\matrix_postprocess.glsl" (
    echo [FALTA] assets\shaders\matrix_postprocess.glsl
    set MISSING=1
)

if !MISSING! == 1 (
    echo [ERROR] Archivos críticos faltantes
    exit /b 1
)

echo [OK] Todos los archivos presentes
echo.

REM Compilar
echo [4/6] Compilando Quake-Matrix...
echo.

mingw32-make -f Makefile.w64 > ..\build_log.txt 2>&1
if errorlevel 1 (
    echo.
    echo [ERROR] Error de compilación
    echo Ver log completo en: build_log.txt
    type ..\build_log.txt
    exit /b 1
)

echo [OK] Compilación exitosa
echo.

REM Verificar binario
echo [5/6] Verificando binario...

if not exist "quakespasm.exe" (
    echo [ERROR] El binario quakespasm.exe no fue creado
    exit /b 1
)

for %%F in (quakespasm.exe) do set BINSIZE=%%~zF
echo [OK] Binario creado: quakespasm.exe (!BINSIZE! bytes)
echo.

REM Verificar DLLs necesarias
echo [6/6] Verificando DLLs necesarias...

set MISSING_DLLS=0

if not exist "SDL.dll" if not exist "SDL2.dll" (
    echo [ADVERTENCIA] SDL.dll o SDL2.dll no encontrada
    echo Copia SDL.dll desde SDL/lib/ al directorio Quake/
    set MISSING_DLLS=1
)

if !MISSING_DLLS! == 1 (
    echo.
    echo [ADVERTENCIA] DLLs faltantes - el ejecutable puede no funcionar
)

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║              COMPILACIÓN COMPLETADA                        ║
echo ╚════════════════════════════════════════════════════════════╝
echo.
echo Binario creado en: Quake\quakespasm.exe
echo.
echo Próximos pasos:
echo 1. Copiar archivos PAK de Quake a: ..\id1\
echo    copy C:\Quake\id1\pak0.pak ..\id1\
echo.
echo 2. Ejecutar desde el directorio raíz:
echo    cd ..
echo    Quake\quakespasm.exe
echo.
echo 3. En la consola (~), probar:
echo    matrix_enable 1
echo    map e1m1
echo.
echo ¡Buena suerte!

cd ..
pause
