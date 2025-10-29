#!/bin/bash
# Script para diagnosticar y reparar problemas con el botón de build en Xcode

echo "🔍 Diagnosticando el proyecto de Xcode..."

PROJECT_PATH="/Users/abrah/Desarrollo de app/Hackathon-Accesibilidad/World  Cup"
cd "$PROJECT_PATH"

echo ""
echo "1. Verificando esquemas disponibles:"
xcodebuild -list -project "World  Cup.xcodeproj" 2>&1 | grep -A 5 "Schemes:"

echo ""
echo "2. Verificando que el esquema compartido existe:"
if [ -f "World  Cup.xcodeproj/xcshareddata/xcschemes/World  Cup.xcscheme" ]; then
    echo "✅ El esquema compartido existe"
else
    echo "❌ El esquema compartido NO existe"
fi

echo ""
echo "3. Verificando permisos del archivo del esquema:"
ls -la "World  Cup.xcodeproj/xcshareddata/xcschemes/World  Cup.xcscheme"

echo ""
echo "4. Limpiando caché de Xcode para este proyecto..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*World*
echo "✅ Caché de DerivedData limpiada"

echo ""
echo "5. Verificando configuración del proyecto:"
xcodebuild -project "World  Cup.xcodeproj" -scheme "World  Cup" -showBuildSettings 2>&1 | grep -E "(PRODUCT_NAME|PRODUCT_BUNDLE_IDENTIFIER|SDKROOT)" | head -5

echo ""
echo "✅ Diagnóstico completado"
echo ""
echo "📋 Pasos siguientes:"
echo "   1. Cierra completamente Xcode (⌘+Q)"
echo "   2. Espera 5 segundos"
echo "   3. Abre Xcode nuevamente"
echo "   4. Abre el proyecto 'World  Cup.xcodeproj'"
echo "   5. En el selector de esquemas (arriba), selecciona 'World  Cup'"
echo "   6. Selecciona un destino (simulador o dispositivo)"
echo "   7. El botón de build (▶️) debería aparecer"

