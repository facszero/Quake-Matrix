@echo off
REM ============================================================================
REM Quake-Matrix - Script de Compilación MEJORADO para Windows 11
REM Con verificación automática de dependencias
REM ============================================================================

setlocal enabledelayedexpansion

echo.
echo ========================================================================
echo         QUAKE-MATRIX - COMPILACION WINDOWS 11
echo ========================================================================
echo.

REM ============================================================================
REM PASO 1: Verificar MinGW
REM ============================================================================
echo [1/7] Verificando MinGW-w64...

where gcc >nul 2>&1
if errorlevel 1 (
    echo [ERROR] gcc no esta instalado o no esta en PATH
    echo.
    echo SOLUCION:
    echo 1. Descarga MinGW-w64 desde:
    echo    https://github.com/niXman/mingw-builds-binaries/releases
    echo.
    echo 2. Busca: x86_64-13.2.0-release-win32-seh-msvcrt-rt_v11-rev1.7z
    echo.
    echo 3. Extrae a: C:\mingw64
    echo.
    echo 4. Agrega al PATH: C:\mingw64\bin
    echo    Windows Key + R ^> sysdm.cpl ^> Variables de entorno
    echo.
    echo 5. REINICIA CMD y vuelve a ejecutar este script
    echo.
    pause
    exit /b 1
)

gcc --version | findstr "x86_64" >nul
if errorlevel 1 (
    echo [ADVERTENCIA] gcc encontrado pero puede no ser x64
)

echo [OK] MinGW-w64 encontrado
for /f "tokens=3" %%v in ('gcc --version ^| findstr "gcc"') do (
    echo     Version: %%v
    goto version_found
)
:version_found
echo.

REM ============================================================================
REM PASO 2: Verificar estructura del proyecto
REM ============================================================================
echo [2/7] Verificando estructura del proyecto...

if not exist "Quake" (
    echo [ERROR] Directorio Quake/ no encontrado
    echo Ejecuta este script desde el directorio raiz de Quake-Matrix
    pause
    exit /b 1
)

if not exist "src" (
    echo [ERROR] Directorio src/ no encontrado
    pause
    exit /b 1
)

if not exist "assets\shaders" (
    echo [ERROR] Directorio assets\shaders\ no encontrado
    pause
    exit /b 1
)

echo [OK] Estructura correcta
echo.

REM ============================================================================
REM PASO 3: Verificar archivos críticos
REM ============================================================================
echo [3/7] Verificando archivos criticos...

set MISSING=0

if not exist "src\gl_matrix.c" (
    echo [FALTA] src\gl_matrix.c
    set MISSING=1
)

if not exist "src\gl_matrix.h" (
    echo [FALTA] src\gl_matrix.h
    set MISSING=1
)

if not exist "assets\shaders\matrix_vertex.glsl" (
    echo [FALTA] assets\shaders\matrix_vertex.glsl
    set MISSING=1
)

if not exist "id1\pak0.pak" (
    echo [ADVERTENCIA] id1\pak0.pak no encontrado
    echo El juego no funcionara sin este archivo
    echo Copia pak0.pak del Quake original a: id1\
    echo.
)

if !MISSING! == 1 (
    echo [ERROR] Archivos criticos faltantes
    pause
    exit /b 1
)

echo [OK] Todos los archivos presentes
echo.

REM ============================================================================
REM PASO 4: Verificar SDL
REM ============================================================================
echo [4/7] Verificando SDL...

if exist "Windows\SDL\lib\libSDL.dll.a" (
    echo [OK] SDL encontrada en Windows\SDL\
) else if exist "Windows\SDL2\lib\libSDL2.dll.a" (
    echo [OK] SDL2 encontrada en Windows\SDL2\
) else (
    echo [ADVERTENCIA] SDL no encontrada en Windows\
    echo El Makefile intentara usar SDL del sistema
)
echo.

REM ============================================================================
REM PASO 5: Limpiar compilación anterior
REM ============================================================================
echo [5/7] Limpiando compilacion anterior...

cd Quake
if exist "*.o" del /q *.o 2>nul
if exist "*.d" del /q *.d 2>nul
if exist "quakespasm.exe" del /q quakespasm.exe 2>nul
if exist "..\src\*.o" del /q ..\src\*.o 2>nul

echo [OK] Limpieza completada
echo.

REM ============================================================================
REM PASO 6: COMPILAR
REM ============================================================================
echo [6/7] Compilando Quake-Matrix...
echo.
echo Esto puede tomar 1-2 minutos...
echo.

REM Compilar con Makefile.w64
mingw32-make -f Makefile.w64 > ..\build_log.txt 2>&1

if errorlevel 1 (
    echo.
    echo [ERROR] Error de compilacion
    echo.
    echo Ultimas 20 lineas del log:
    echo ----------------------------------------
    type ..\build_log.txt | more +100
    echo ----------------------------------------
    echo.
    echo Ver log completo en: build_log.txt
    echo.
    pause
    exit /b 1
)

echo [OK] Compilacion exitosa
echo.

REM ============================================================================
REM PASO 7: Verificar binario
REM ============================================================================
echo [7/7] Verificando binario...

if not exist "quakespasm.exe" (
    echo [ERROR] quakespasm.exe no fue creado
    echo Revisa build_log.txt para detalles
    pause
    exit /b 1
)

for %%F in (quakespasm.exe) do set BINSIZE=%%~zF
set /a BINSIZE_MB=!BINSIZE! / 1048576

echo [OK] Binario creado: quakespasm.exe (!BINSIZE_MB! MB)
echo.

REM Verificar DLLs
echo Verificando DLLs necesarias...

set MISSING_DLLS=0

if not exist "SDL.dll" if not exist "SDL2.dll" (
    echo [INFO] Copiando SDL.dll...
    if exist "..\Windows\SDL\lib\SDL.dll" (
        copy /y "..\Windows\SDL\lib\SDL.dll" . >nul
        echo [OK] SDL.dll copiada
    ) else if exist "..\Windows\SDL2\lib64\SDL2.dll" (
        copy /y "..\Windows\SDL2\lib64\SDL2.dll" . >nul
        echo [OK] SDL2.dll copiada
    ) else (
        echo [ADVERTENCIA] SDL.dll no encontrada
        echo Descarga SDL2 desde: https://github.com/libsdl-org/SDL/releases
        echo Copia SDL2.dll al directorio Quake\
        set MISSING_DLLS=1
    )
)

echo.
echo ========================================================================
echo              COMPILACION COMPLETADA EXITOSAMENTE
echo ========================================================================
echo.
echo Binario: Quake\quakespasm.exe (!BINSIZE_MB! MB)
echo.

if !MISSING_DLLS! == 1 (
    echo [ADVERTENCIA] Faltan DLLs - copia SDL2.dll antes de ejecutar
    echo.
)

echo PROXIMOS PASOS:
echo.
echo 1. Verifica que id1\pak0.pak exista
if not exist "..\id1\pak0.pak" (
    echo    [PENDIENTE] Copia pak0.pak a: ..\id1\
)
echo.
echo 2. Ejecuta el juego:
echo    cd ..
echo    Quake\quakespasm.exe
echo.
echo 3. En la consola (~):
echo    matrix_enable 1
echo    map e1m1
echo.
echo 4. Comandos utiles:
echo    matrix_rainspeed 5.0
echo    matrix_density 30
echo    matrix_glow 2.0
echo.

cd ..
pause
