#!/bin/bash

# Script para actualizar la configuración de Continue con todos los modelos disponibles

echo "🔄 Actualizando configuración de Continue..."

# Detectar contenedor de Ollama
CONTAINER=$(docker ps --format "table {{.Names}}" | grep "ollama" | head -n 1)

if [ -z "$CONTAINER" ]; then
    echo "❌ No se encontró contenedor de Ollama ejecutándose"
    exit 1
fi

echo "📋 Obteniendo lista de modelos instalados..."
MODELS=$(docker exec $CONTAINER ollama list | grep -v "NAME" | awk '{print $1}' | grep -v "^$")

# Crear configuración dinámica de Continue
cat > continue-config.json << EOF
{
  "models": [
    {
      "title": "Qwen 2.5 Coder 7B - Programación",
      "provider": "ollama",
      "model": "qwen2.5-coder:7b",
      "apiBase": "http://localhost:11434"
    },
    {
      "title": "DeepSeek Coder 6.7B - Código",
      "provider": "ollama",
      "model": "deepseek-coder:6.7b",
      "apiBase": "http://localhost:11434"
    },
    {
      "title": "CodeLlama 7B - Desarrollo",
      "provider": "ollama",
      "model": "codellama:7b",
      "apiBase": "http://localhost:11434"
    },
    {
      "title": "Llama 3.1 8B - General",
      "provider": "ollama",
      "model": "llama3.1:8b",
      "apiBase": "http://localhost:11434"
    },
    {
      "title": "Llama 3.2 1B - Rápido",
      "provider": "ollama",
      "model": "llama3.2:1b",
      "apiBase": "http://localhost:11434"
    }
  ],
  "customCommands": [
    {
      "name": "explain",
      "prompt": "Explica este código en español de forma clara y detallada: {{{ input }}}"
    },
    {
      "name": "optimize",
      "prompt": "Optimiza este código para mejor rendimiento y legibilidad: {{{ input }}}"
    },
    {
      "name": "fix",
      "prompt": "Encuentra y corrige los errores en este código: {{{ input }}}"
    },
    {
      "name": "test",
      "prompt": "Genera tests unitarios para este código: {{{ input }}}"
    },
    {
      "name": "document", 
      "prompt": "Genera documentación completa para este código incluyendo JSDoc/docstrings: {{{ input }}}"
    },
    {
      "name": "refactor",
      "prompt": "Refactoriza este código siguiendo las mejores prácticas: {{{ input }}}"
    }
  ],
  "contextLength": 8192,
  "completionOptions": {
    "temperature": 0.2,
    "topP": 0.9,
    "presencePenalty": 0.0,
    "frequencyPenalty": 0.0
  },
  "allowAnonymousTelemetry": false
}
EOF

echo "✅ Configuración de Continue actualizada con todos los modelos disponibles:"
echo "$MODELS"
echo ""
echo "🔧 Para aplicar los cambios:"
echo "  1. Reinicia VS Code o"
echo "  2. Recarga la ventana de VS Code (Ctrl+Shift+P -> 'Developer: Reload Window')"
echo ""
echo "📍 Ubicación del archivo: $(pwd)/continue-config.json"
