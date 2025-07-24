#!/bin/bash

# Script simple y rápido para configurar IA local sin conflictos de puertos
# Autor: Script generado para AgentOllamaAi

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Configuración rápida de IA local (puertos actualizados)...${NC}"

# 1. Limpieza rápida
echo -e "${YELLOW}🧹 Limpiando servicios anteriores...${NC}"
docker-compose down --remove-orphans 2>/dev/null || true
docker compose down --remove-orphans 2>/dev/null || true

# Liberar puertos específicos
pkill -f "docker-proxy.*(11434|3001)" 2>/dev/null || true
sleep 2

echo -e "${GREEN}✅ Limpieza completada${NC}"

# 2. Detectar perfil
echo -e "${YELLOW}🔍 Detectando configuración óptima...${NC}"
if command -v nvidia-smi &> /dev/null && nvidia-smi > /dev/null 2>&1; then
    # Verificar si Docker puede usar GPU
    if docker run --rm --runtime=nvidia --gpus all nvidia/cuda:11.0.3-base-ubuntu20.04 nvidia-smi &> /dev/null; then
        PROFILE="gpu"
        echo -e "${GREEN}✅ Usando GPU NVIDIA${NC}"
    else
        PROFILE="cpu"  
        echo -e "${YELLOW}⚠️ GPU detectada pero no compatible con Docker, usando CPU${NC}"
    fi
else
    PROFILE="cpu"
    echo -e "${YELLOW}⚠️ Usando CPU${NC}"
fi

# 3. Iniciar servicios
echo -e "${YELLOW}🐳 Iniciando servicios...${NC}"
docker compose --profile $PROFILE up -d

# 4. Esperar y verificar
echo -e "${YELLOW}⏳ Esperando a que Ollama esté listo...${NC}"
sleep 10

for i in {1..6}; do
    if curl -s http://localhost:11434/api/version > /dev/null; then
        echo -e "${GREEN}✅ Ollama funcionando correctamente${NC}"
        break
    else
        echo "Esperando... ($i/6)"
        sleep 5
    fi
    
    if [ $i -eq 6 ]; then
        echo -e "${RED}❌ Ollama no responde. Verificando logs...${NC}"
        docker logs ollama-dev-ai 2>/dev/null | tail -10 || docker logs ollama-dev-ai-cpu 2>/dev/null | tail -10
        exit 1
    fi
done

# 5. Descargar solo modelos esenciales
echo -e "${YELLOW}📥 Descargando modelos básicos...${NC}"
CONTAINER_NAME="ollama-dev-ai"
if [ "$PROFILE" = "cpu" ]; then
    CONTAINER_NAME="ollama-dev-ai-cpu"
fi

echo "   📦 Descargando llama3.2:1b (rápido)..."
docker exec $CONTAINER_NAME ollama pull llama3.2:1b

echo "   📦 Descargando qwen2.5-coder:7b (código)..."
docker exec $CONTAINER_NAME ollama pull qwen2.5-coder:7b

echo "   📦 Descargando deepseek-coder:6.7b (programación)..."
docker exec $CONTAINER_NAME ollama pull deepseek-coder:6.7b

# 6. Configurar Continue
echo -e "${YELLOW}🔧 Configurando Continue...${NC}"
if [ -f "continue-config.json" ]; then
    mkdir -p "$HOME/.continue"
    cp "continue-config.json" "$HOME/.continue/config.json"
    echo -e "${GREEN}✅ Continue configurado${NC}"
fi

# 7. Resultado final
echo ""
echo -e "${GREEN}🎉 ¡Configuración completada!${NC}"
echo -e "${BLUE}🔗 URLs disponibles:${NC}"
echo "   • Ollama API: http://localhost:11434"
echo "   • Web UI: http://localhost:3001"
echo ""
echo -e "${YELLOW}📝 Siguiente paso:${NC}"
echo "   Reinicia VS Code y abre Continue"
echo ""
echo -e "${BLUE}🧠 Modelos instalados:${NC}"
docker exec $CONTAINER_NAME ollama list | tail -n +2 | while read line; do
    model_name=$(echo $line | awk '{print $1}')
    echo "   • $model_name"
done
