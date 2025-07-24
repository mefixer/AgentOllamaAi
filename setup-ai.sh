#!/bin/bash

# Script para configurar una IA local para desarrollo con los mejores modelos de código abierto

echo "🤖 Configurando IA local para desarrollo..."

# Función para limpiar recursos previos
cleanup_previous_setup() {
    echo "🧹 Limpiando configuración anterior..."
    
    # Detener y eliminar contenedores relacionados con Ollama
    echo "🛑 Deteniendo contenedores existentes..."
    docker stop $(docker ps -q --filter "name=ollama") 2>/dev/null || true
    docker stop $(docker ps -q --filter "name=open-webui") 2>/dev/null || true
    
    # Eliminar contenedores
    echo "🗑️  Eliminando contenedores antiguos..."
    docker rm $(docker ps -aq --filter "name=ollama") 2>/dev/null || true
    docker rm $(docker ps -aq --filter "name=open-webui") 2>/dev/null || true
    
    # Eliminar redes personalizadas (pero mantener las predeterminadas)
    echo "🌐 Limpiando redes no utilizadas..."
    docker network prune -f 2>/dev/null || true
    
    # Limpiar volúmenes huérfanos
    echo "💾 Limpiando volúmenes no utilizados..."
    docker volume prune -f 2>/dev/null || true
    
    # Verificar que el puerto 11434 esté liberado
    echo "🔍 Verificando liberación del puerto 11434..."
    if netstat -tlnp 2>/dev/null | grep :11434 > /dev/null; then
        echo "⚠️  El puerto 11434 aún está ocupado. Esperando 5 segundos..."
        sleep 5
        # Intentar matar procesos que usen el puerto (con precaución)
        sudo pkill -f "docker-proxy.*11434" 2>/dev/null || true
        sleep 2
    fi
    
    echo "✅ Limpieza completada"
}

# Ejecutar limpieza antes de configurar
cleanup_previous_setup

# Detectar si el sistema tiene GPU NVIDIA
if command -v nvidia-smi &> /dev/null; then
    echo "✅ GPU NVIDIA detectada"
    PROFILE="gpu"
else
    echo "⚠️  No se detectó GPU NVIDIA, usando CPU"
    PROFILE="cpu"
fi

# Levantar los servicios
echo "🐳 Iniciando servicios Docker..."
docker compose --profile $PROFILE up -d

# Esperar a que Ollama esté listo
echo "⏳ Esperando a que Ollama esté listo..."
sleep 10

# Descargar los mejores modelos de código abierto para desarrollo
echo "📥 Descargando modelos de IA para desarrollo..."

# CodeLlama 34B - Excelente para código
echo "Descargando CodeLlama 34B (especializado en código)..."
docker exec ollama-dev-ai-${PROFILE} ollama pull codellama:34b

# Llama 3.1 8B - Muy bueno y rápido
echo "Descargando Llama 3.1 8B (rápido y eficiente)..."
docker exec ollama-dev-ai-${PROFILE} ollama pull llama3.1:8b

# DeepSeek Coder 33B - Especializado en programación
echo "Descargando DeepSeek Coder 33B (especialista en código)..."
docker exec ollama-dev-ai-${PROFILE} ollama pull deepseek-coder:33b

# Qwen 2.5 Coder 32B - Uno de los mejores para código
echo "Descargando Qwen 2.5 Coder 32B (excelente para código)..."
docker exec ollama-dev-ai-${PROFILE} ollama pull qwen2.5-coder:32b

# Granite Code 34B - Modelo de IBM para código
echo "Descargando Granite Code 34B (modelo de IBM)..."
docker exec ollama-dev-ai-${PROFILE} ollama pull granite-code:34b

# Establecer modelo por defecto
echo "🎯 Configurando modelo por defecto..."
docker exec ollama-dev-ai-${PROFILE} ollama pull qwen2.5-coder:7b

echo "✅ ¡Configuración completada!"
echo ""
echo "🔗 URLs disponibles:"
echo "   • Ollama API: http://localhost:11434"
echo "   • Web UI: http://localhost:3001"
echo ""
echo "📝 Modelos instalados:"
echo "   • qwen2.5-coder:32b (recomendado para código complejo)"
echo "   • qwen2.5-coder:7b (rápido para código simple)"
echo "   • codellama:34b (especialista en código)"
echo "   • llama3.1:8b (uso general rápido)"
echo "   • deepseek-coder:33b (experto en programación)"
echo "   • granite-code:34b (modelo IBM para código)"
echo ""
echo "🛠️  Para usar en VS Code, instala la extensión 'Continue' y configúrala con:"
echo "   URL: http://localhost:11434"
echo "   Modelo recomendado: qwen2.5-coder:7b"
