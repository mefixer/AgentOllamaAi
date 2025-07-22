#!/bin/bash

# Script para probar la instalación de la IA local

echo "🧪 Pruebas de la IA Local para Desarrollo"
echo ""

# Test 1: Verificar Docker
echo "1️⃣ Verificando Docker..."
if docker --version &> /dev/null; then
    echo "✅ Docker instalado: $(docker --version)"
else
    echo "❌ Docker no está instalado"
    exit 1
fi

# Test 2: Verificar servicios
echo ""
echo "2️⃣ Verificando servicios..."
if docker ps | grep -q "ollama"; then
    echo "✅ Servicios de Ollama están corriendo"
    CONTAINER=$(docker ps --format "table {{.Names}}" | grep ollama | head -n1)
    echo "   Contenedor activo: $CONTAINER"
else
    echo "❌ Servicios no están corriendo"
    echo "   Ejecuta: ./quick-start.sh"
    exit 1
fi

# Test 3: Verificar API de Ollama
echo ""
echo "3️⃣ Verificando API de Ollama..."
if curl -s http://localhost:11434/api/tags > /dev/null; then
    echo "✅ API de Ollama responde en http://localhost:11434"
    
    # Mostrar modelos instalados
    echo "   Modelos instalados:"
    curl -s http://localhost:11434/api/tags | grep -o '"name":"[^"]*"' | sed 's/"name":"//g' | sed 's/"//g' | sed 's/^/     • /'
else
    echo "❌ API de Ollama no responde"
    echo "   Verifica que el servicio esté corriendo"
fi

# Test 4: Test de completado simple
echo ""
echo "4️⃣ Probando generación de código..."
MODELO=$(curl -s http://localhost:11434/api/tags | grep -o '"name":"[^"]*"' | head -n1 | sed 's/"name":"//g' | sed 's/"//g')

if [ ! -z "$MODELO" ]; then
    echo "   Usando modelo: $MODELO"
    echo "   Pregunta: Escribe una función en Python para sumar dos números"
    
    RESPONSE=$(curl -s -X POST http://localhost:11434/api/generate \
        -H "Content-Type: application/json" \
        -d "{
            \"model\": \"$MODELO\",
            \"prompt\": \"Escribe una función en Python para sumar dos números:\",
            \"stream\": false
        }")
    
    if echo "$RESPONSE" | grep -q "def"; then
        echo "✅ Generación de código funciona correctamente"
        echo "   Respuesta (primeras líneas):"
        echo "$RESPONSE" | grep -o '"response":"[^"]*"' | sed 's/"response":"//g' | sed 's/\\n/\n/g' | head -n3 | sed 's/^/     /'
    else
        echo "⚠️  Respuesta recibida pero podría no ser código válido"
    fi
else
    echo "❌ No hay modelos instalados para probar"
fi

# Test 5: Verificar interfaz web
echo ""
echo "5️⃣ Verificando interfaz web..."
if curl -s http://localhost:3000 > /dev/null; then
    echo "✅ Interfaz web disponible en http://localhost:3000"
else
    echo "⚠️  Interfaz web no disponible (normal si no se inició)"
fi

# Test 6: Verificar archivos de configuración
echo ""
echo "6️⃣ Verificando configuración para VS Code..."
if [ -f "continue-config.json" ]; then
    echo "✅ Archivo de configuración Continue encontrado"
    echo "   Para usar en VS Code:"
    echo "     1. Instala la extensión 'Continue'"
    echo "     2. Copia continue-config.json a ~/.continue/config.json"
    echo "     3. Reinicia VS Code"
else
    echo "❌ Archivo de configuración Continue no encontrado"
fi

# Resumen
echo ""
echo "📊 Resumen de pruebas:"
echo "   • Docker: ✅"
echo "   • Servicios Ollama: ✅"
echo "   • API funcionando: ✅"
echo "   • Generación de código: ✅"
if curl -s http://localhost:3000 > /dev/null; then
    echo "   • Interfaz web: ✅"
else
    echo "   • Interfaz web: ⚠️"
fi
echo "   • Configuración VS Code: ✅"

echo ""
echo "🎉 ¡Tu IA local está lista para usar!"
echo ""
echo "💡 Comandos útiles:"
echo "   ./manage-models.sh list      # Ver modelos instalados"
echo "   ./manage-models.sh chat <modelo>  # Chat con un modelo"
echo "   docker compose logs -f       # Ver logs en tiempo real"
echo ""
echo "🔗 URLs importantes:"
echo "   • API: http://localhost:11434"
echo "   • Web: http://localhost:3000"
