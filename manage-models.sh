#!/bin/bash

# Script para gestionar modelos de IA

show_help() {
    echo "🤖 Gestión de Modelos de IA Local"
    echo ""
    echo "Uso: $0 [comando] [opciones]"
    echo ""
    echo "Comandos disponibles:"
    echo "  list              Lista todos los modelos instalados"
    echo "  download <modelo> Descarga un modelo específico"
    echo "  remove <modelo>   Elimina un modelo"
    echo "  chat <modelo>     Inicia chat interactivo con un modelo"
    echo "  status            Muestra el estado de los servicios"
    echo "  recommended       Descarga solo los modelos recomendados"
    echo "  lightweight       Descarga solo modelos ligeros (< 10GB)"
    echo "  full             Descarga todos los modelos disponibles"
    echo "  update-continue   Actualiza configuración de Continue con modelos actuales"
    echo ""
    echo "Ejemplos:"
    echo "  $0 chat qwen2.5-coder:7b"
    echo "  $0 download codellama:13b"
    echo "  $0 remove llama3.1:8b"
}

detect_container() {
    if docker ps | grep -q "ollama-dev-ai-gpu"; then
        echo "ollama-dev-ai-gpu"
    elif docker ps | grep -q "ollama-dev-ai-cpu"; then
        echo "ollama-dev-ai-cpu"
    elif docker ps | grep -q "ollama-dev-ai"; then
        echo "ollama-dev-ai"
    else
        echo "error"
    fi
}

case "$1" in
    "list")
        CONTAINER=$(detect_container)
        if [ "$CONTAINER" = "error" ]; then
            echo "❌ No se encontró contenedor de Ollama ejecutándose"
            exit 1
        fi
        echo "📋 Modelos instalados:"
        docker exec $CONTAINER ollama list
        ;;
    
    "download")
        if [ -z "$2" ]; then
            echo "❌ Especifica el modelo a descargar"
            echo "Ejemplo: $0 download qwen2.5-coder:7b"
            exit 1
        fi
        CONTAINER=$(detect_container)
        if [ "$CONTAINER" = "error" ]; then
            echo "❌ No se encontró contenedor de Ollama ejecutándose"
            exit 1
        fi
        echo "📥 Descargando $2..."
        docker exec $CONTAINER ollama pull $2
        ;;
    
    "remove")
        if [ -z "$2" ]; then
            echo "❌ Especifica el modelo a eliminar"
            echo "Ejemplo: $0 remove llama3.1:8b"
            exit 1
        fi
        CONTAINER=$(detect_container)
        if [ "$CONTAINER" = "error" ]; then
            echo "❌ No se encontró contenedor de Ollama ejecutándose"
            exit 1
        fi
        echo "🗑️ Eliminando $2..."
        docker exec $CONTAINER ollama rm $2
        ;;
    
    "chat")
        if [ -z "$2" ]; then
            echo "❌ Especifica el modelo para chat"
            echo "Ejemplo: $0 chat qwen2.5-coder:7b"
            exit 1
        fi
        CONTAINER=$(detect_container)
        if [ "$CONTAINER" = "error" ]; then
            echo "❌ No se encontró contenedor de Ollama ejecutándose"
            exit 1
        fi
        echo "💬 Iniciando chat con $2..."
        echo "Tip: Escribe '/bye' para salir"
        docker exec -it $CONTAINER ollama run $2
        ;;
    
    "status")
        echo "📊 Estado de los servicios:"
        docker compose ps
        echo ""
        echo "🌐 URLs disponibles:"
        echo "  • API Ollama: http://localhost:11434"
        echo "  • Web UI: http://localhost:3000"
        ;;
    
    "recommended")
        CONTAINER=$(detect_container)
        if [ "$CONTAINER" = "error" ]; then
            echo "❌ Inicia los servicios primero con: docker compose up -d"
            exit 1
        fi
        echo "📥 Descargando modelos recomendados..."
        docker exec $CONTAINER ollama pull qwen2.5-coder:7b
        docker exec $CONTAINER ollama pull llama3.1:8b
        docker exec $CONTAINER ollama pull deepseek-coder:7b
        echo "✅ Modelos recomendados instalados"
        ;;
    
    "lightweight")
        CONTAINER=$(detect_container)
        if [ "$CONTAINER" = "error" ]; then
            echo "❌ Inicia los servicios primero con: docker compose up -d"
            exit 1
        fi
        echo "📥 Descargando modelos ligeros..."
        docker exec $CONTAINER ollama pull qwen2.5-coder:7b
        docker exec $CONTAINER ollama pull llama3.1:8b
        docker exec $CONTAINER ollama pull codellama:7b
        docker exec $CONTAINER ollama pull deepseek-coder:7b
        echo "✅ Modelos ligeros instalados"
        ;;
    
    "full")
        CONTAINER=$(detect_container)
        if [ "$CONTAINER" = "error" ]; then
            echo "❌ Inicia los servicios primero con: docker compose up -d"
            exit 1
        fi
        echo "📥 Descargando todos los modelos (esto puede tardar mucho)..."
        docker exec $CONTAINER ollama pull qwen2.5-coder:32b
        docker exec $CONTAINER ollama pull qwen2.5-coder:7b
        docker exec $CONTAINER ollama pull codellama:34b
        docker exec $CONTAINER ollama pull codellama:13b
        docker exec $CONTAINER ollama pull codellama:7b
        docker exec $CONTAINER ollama pull deepseek-coder:33b
        docker exec $CONTAINER ollama pull deepseek-coder:7b
        docker exec $CONTAINER ollama pull llama3.1:8b
        docker exec $CONTAINER ollama pull granite-code:34b
        echo "✅ Todos los modelos instalados"
        ;;
    
    "update-continue")
        echo "🔄 Actualizando configuración de Continue..."
        if [ -f "update-continue-config.sh" ]; then
            ./update-continue-config.sh
            cp continue-config.json ~/.continue/config.json
            echo "✅ Configuración de Continue actualizada"
            echo "💡 Reinicia VS Code para aplicar los cambios"
        else
            echo "❌ No se encontró el script update-continue-config.sh"
        fi
        ;;

    "help"|"-h"|"--help"|"")
        show_help
        ;;
    
    *)
        echo "❌ Comando desconocido: $1"
        echo "Usa '$0 help' para ver los comandos disponibles"
        exit 1
        ;;
esac
