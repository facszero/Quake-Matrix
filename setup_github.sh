#!/bin/bash

# Script para subir Quake-Matrix a GitHub
# Proyecto por Fernando Cañete (facszero)

echo "================================================"
echo "  Quake-Matrix - Setup GitHub Repository"
echo "================================================"
echo ""

# Verificar que estamos en el directorio correcto
if [ ! -d ".git" ]; then
    echo "❌ Error: No se encuentra repositorio Git"
    echo "   Ejecuta este script desde el directorio raíz de Quake-Matrix"
    exit 1
fi

echo "📋 Configuración del repositorio:"
echo "   Usuario: facszero"
echo "   Repo: Quake-Matrix"
echo "   Email: facs.zero@gmail.com"
echo "   Autor: Fernando Cañete"
echo ""

# Verificar configuración Git
echo "🔍 Verificando configuración Git..."
git config user.name "Fernando Cañete"
git config user.email "facs.zero@gmail.com"

echo "✅ Configuración de Git completa"
echo ""

# Mostrar estado del repositorio
echo "📊 Estado del repositorio:"
git status --short
echo ""

# Mostrar commits
echo "📜 Historial de commits:"
git log --oneline -10
echo ""

echo "================================================"
echo "  Próximos pasos para subir a GitHub"
echo "================================================"
echo ""
echo "1. Crea el repositorio en GitHub:"
echo "   https://github.com/new"
echo "   Nombre: Quake-Matrix"
echo "   Descripción: Motor Quake en el Universo Matrix"
echo "   Público ✓"
echo "   NO inicialices con README, .gitignore o licencia"
echo ""
echo "2. Ejecuta estos comandos:"
echo ""
echo "   git remote add origin https://github.com/facszero/Quake-Matrix.git"
echo "   git branch -M master"
echo "   git push -u origin master"
echo ""
echo "3. Si necesitas usar un Personal Access Token:"
echo "   Ve a: Settings > Developer Settings > Personal access tokens"
echo "   Crea un token con permisos 'repo'"
echo "   Usa el token como contraseña al hacer push"
echo ""
echo "================================================"
echo ""

# Preguntar si quiere continuar automáticamente
read -p "¿Agregar remote y hacer push ahora? (necesitas token de GitHub) [y/N]: " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "🔗 Agregando remote 'origin'..."
    
    # Verificar si ya existe el remote
    if git remote | grep -q "^origin$"; then
        echo "   ⚠️  Remote 'origin' ya existe"
        read -p "   ¿Reemplazar? [y/N]: " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git remote remove origin
            git remote add origin https://github.com/facszero/Quake-Matrix.git
            echo "   ✅ Remote actualizado"
        fi
    else
        git remote add origin https://github.com/facszero/Quake-Matrix.git
        echo "   ✅ Remote agregado"
    fi
    
    echo ""
    echo "🌿 Configurando rama master..."
    git branch -M master
    echo "   ✅ Rama configurada"
    
    echo ""
    echo "📤 Subiendo a GitHub..."
    echo "   (Se te pedirá tu token de GitHub como contraseña)"
    echo ""
    
    git push -u origin master
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "================================================"
        echo "  ✅ ¡ÉXITO!"
        echo "================================================"
        echo ""
        echo "Tu repositorio está ahora en:"
        echo "https://github.com/facszero/Quake-Matrix"
        echo ""
        echo "Siguientes pasos sugeridos:"
        echo "1. Agrega topics en GitHub: 'quake', 'matrix', 'game-engine', 'opengl'"
        echo "2. Activa GitHub Pages si quieres una página web"
        echo "3. Considera agregar:"
        echo "   - GitHub Actions para CI/CD"
        echo "   - Releases con binarios compilados"
        echo "   - Screenshots/GIFs del efecto Matrix"
        echo ""
    else
        echo ""
        echo "❌ Error al hacer push"
        echo "   Verifica tu token de GitHub y permisos"
        echo ""
    fi
else
    echo ""
    echo "ℹ️  No se hizo push automático"
    echo "   Puedes hacerlo manualmente cuando estés listo"
    echo ""
fi

echo "================================================"
echo ""
