@echo off
REM ============================================================================
REM Quake-Matrix - Verificador de Requisitos para Windows 11
REM Verifica que todo esté listo ANTES de compilar
REM ============================================================================

setlocal enabledelayedexpansion

echo.
echo ========================================================================
echo      QUAKE-MATRIX - VERIFICADOR DE REQUISITOS WINDOWS 11
echo ========================================================================
echo.

set READY=1
set WARNINGS=0

REM ============================================================================
REM 1. VERIFICAR GCC
REM ============================================================================
echo [1/6] Verificando GCC (MinGW)...

where gcc >nul 2>&1
if errorlevel 1 (
    echo [X] FALTA: gcc no encontrado en PATH
    echo.
    echo     SOLUCION:
    echo     1. Instala MSYS2: https://www.msys2.org/
    echo     2. En MSYS2: pacman -S mingw-w64-x86_64-gcc
    echo     3. Agrega al PATH: C:\msys64\mingw64\bin
    echo     4. REINICIA CMD
    echo.
    set READY=0
) else (
    gcc --version | findstr "gcc" >nul
    if errorlevel 1 (
        echo [!] ADVERTENCIA: gcc encontrado pero version desconocida
        set WARNINGS=1
    ) else (
        for /f "tokens=3" %%v in ('gcc --version ^| findstr "gcc"') do (
            echo [OK] gcc version %%v
        )
    )
)
echo.

REM ============================================================================
REM 2. VERIFICAR MAKE
REM ============================================================================
echo [2/6] Verificando Make...

where mingw32-make >nul 2>&1
if errorlevel 1 (
    where make >nul 2>&1
    if errorlevel 1 (
        echo [X] FALTA: make / mingw32-make no encontrado
        echo.
        echo     SOLUCION:
        echo     En MSYS2: pacman -S mingw-w64-x86_64-make
        echo.
        set READY=0
    ) else (
        echo [OK] make encontrado
    )
) else (
    echo [OK] mingw32-make encontrado
)
echo.

REM ============================================================================
REM 3. VERIFICAR ESTRUCTURA DEL PROYECTO
REM ============================================================================
echo [3/6] Verificando estructura del proyecto...

if not exist "Quake" (
    echo [X] FALTA: Directorio Quake\
    echo     Ejecuta desde el directorio raiz de Quake-Matrix
    set READY=0
) else (
    echo [OK] Quake\
)

if not exist "src" (
    echo [X] FALTA: Directorio src\
    set READY=0
) else (
    echo [OK] src\
)

if not exist "assets\shaders" (
    echo [X] FALTA: Directorio assets\shaders\
    set READY=0
) else (
    echo [OK] assets\shaders\
)

if not exist "id1" (
    echo [!] ADVERTENCIA: Directorio id1\ no existe
    echo     Crea: mkdir id1
    set WARNINGS=1
) else (
    echo [OK] id1\
)

echo.

REM ============================================================================
REM 4. VERIFICAR ARCHIVOS CRÍTICOS
REM ============================================================================
echo [4/6] Verificando archivos criticos...

if not exist "src\gl_matrix.c" (
    echo [X] FALTA: src\gl_matrix.c
    set READY=0
) else (
    echo [OK] src\gl_matrix.c
)

if not exist "src\gl_matrix.h" (
    echo [X] FALTA: src\gl_matrix.h
    set READY=0
) else (
    echo [OK] src\gl_matrix.h
)

if not exist "assets\shaders\matrix_vertex.glsl" (
    echo [X] FALTA: assets\shaders\matrix_vertex.glsl
    set READY=0
) else (
    echo [OK] assets\shaders\matrix_vertex.glsl
)

if not exist "assets\shaders\matrix_fragment.glsl" (
    echo [X] FALTA: assets\shaders\matrix_fragment.glsl
    set READY=0
) else (
    echo [OK] assets\shaders\matrix_fragment.glsl
)

if not exist "Quake\Makefile.w64" (
    echo [X] FALTA: Quake\Makefile.w64
    set READY=0
) else (
    echo [OK] Quake\Makefile.w64
)

echo.

REM ============================================================================
REM 5. VERIFICAR pak0.pak
REM ============================================================================
echo [5/6] Verificando pak0.pak...

if not exist "id1\pak0.pak" (
    echo [!] ADVERTENCIA: id1\pak0.pak no encontrado
    echo.
    echo     El juego NO funcionara sin este archivo
    echo.
    echo     SOLUCION:
    echo     - Si tienes Quake en Steam:
    echo       copy "C:\Program Files (x86)\Steam\steamapps\common\Quake\id1\pak0.pak" id1\
    echo.
    echo     - Si tienes Quake en GOG:
    echo       copy "C:\GOG Games\Quake\id1\pak0.pak" id1\
    echo.
    echo     - Si descargaste PAK0.PAK:
    echo       copy "%%USERPROFILE%%\Downloads\PAK0.PAK" id1\pak0.pak
    echo.
    set WARNINGS=1
) else (
    for %%F in (id1\pak0.pak) do set PAKSIZE=%%~zF
    set /a PAKSIZE_MB=!PAKSIZE! / 1048576
    
    if !PAKSIZE_MB! LSS 15 (
        echo [!] ADVERTENCIA: pak0.pak parece corrupto ^(!PAKSIZE_MB! MB^)
        echo     Deberia ser ~18 MB
        set WARNINGS=1
    ) else (
        echo [OK] pak0.pak ^(!PAKSIZE_MB! MB^)
    )
)
echo.

REM ============================================================================
REM 6. VERIFICAR ESPACIO EN DISCO
REM ============================================================================
echo [6/6] Verificando espacio en disco...

for /f "tokens=3" %%a in ('dir /-c ^| findstr "bytes free"') do set FREE=%%a
set /a FREE_MB=!FREE! / 1048576

if !FREE_MB! LSS 500 (
    echo [!] ADVERTENCIA: Poco espacio libre ^(!FREE_MB! MB^)
    echo     Recomendado: 2 GB libre
    set WARNINGS=1
) else (
    echo [OK] Espacio libre: !FREE_MB! MB
)

echo.

REM ============================================================================
REM RESUMEN
REM ============================================================================
echo ========================================================================
echo                          RESUMEN
echo ========================================================================
echo.

if !READY! == 1 (
    if !WARNINGS! == 0 (
        echo [OK] SISTEMA LISTO PARA COMPILAR
        echo.
        echo PROXIMO PASO:
        echo   build_windows_mejorado.bat
        echo.
    ) else (
        echo [!] SISTEMA LISTO CON ADVERTENCIAS
        echo.
        echo Puedes compilar, pero revisa las advertencias arriba.
        echo.
        echo PROXIMO PASO:
        echo   build_windows_mejorado.bat
        echo.
    )
) else (
    echo [X] SISTEMA NO LISTO
    echo.
    echo Resuelve los errores marcados con [X] arriba.
    echo.
)

echo ========================================================================
echo.

pause
exit /b !READY!
