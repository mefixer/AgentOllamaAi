#!/bin/bash

# Script para limpiar y reconfigurar completamente la IA local
# Autor: Script generado para AgentOllamaAi

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔄 Limpieza y reconfiguración completa del sistema AI...${NC}"

# Función para verificar puerto
check_port() {
    local port=$1
    if sudo netstat -tlnp | grep ":$port " > /dev/null 2>&1; then
        return 0  # Puerto ocupado
    else
        return 1  # Puerto libre
    fi
}

# 1. Limpieza completa
echo -e "${YELLOW}🧹 Paso 1: Limpieza completa...${NC}"

# Detener servicios Docker Compose
echo "Deteniendo servicios Docker Compose..."
docker-compose down --remove-orphans 2>/dev/null || true
docker compose down --remove-orphans 2>/dev/null || true

# Detener y eliminar contenedores relacionados
echo "Eliminando contenedores relacionados..."
docker stop $(docker ps -q --filter "name=ollama") 2>/dev/null || true
docker stop $(docker ps -q --filter "name=open-webui") 2>/dev/null || true
docker rm $(docker ps -aq --filter "name=ollama") 2>/dev/null || true
docker rm $(docker ps -aq --filter "name=open-webui") 2>/dev/null || true

# Liberar puerto 11434 de forma agresiva
echo "Liberando puerto 11434..."
if check_port 11434; then
    echo "Puerto 11434 ocupado, liberando..."
    sudo pkill -f "docker-proxy.*11434" 2>/dev/null || true
    sudo lsof -ti :11434 | xargs sudo kill -9 2>/dev/null || true
    sleep 3
fi

# Limpiar recursos Docker
echo "Limpiando recursos Docker..."
docker network prune -f 2>/dev/null || true
docker volume prune -f 2>/dev/null || true

# Reiniciar Docker si es necesario
if check_port 11434; then
    echo "Reiniciando Docker daemon para liberar completamente los recursos..."
    sudo systemctl restart docker
    sleep 10
fi

echo -e "${GREEN}✅ Limpieza completada${NC}"

# 2. Verificar que el puerto esté libre
echo -e "${YELLOW}🔍 Paso 2: Verificando puerto 11434...${NC}"
if check_port 11434; then
    echo -e "${RED}❌ El puerto 11434 aún está ocupado. Abortando.${NC}"
    echo "Ejecuta manualmente: sudo lsof -i :11434"
    exit 1
else
    echo -e "${GREEN}✅ Puerto 11434 libre${NC}"
fi

# 3. Detectar GPU y configurar perfil
echo -e "${YELLOW}🔍 Paso 3: Detectando hardware...${NC}"
if command -v nvidia-smi &> /dev/null && nvidia-smi > /dev/null 2>&1; then
    echo -e "${GREEN}✅ GPU NVIDIA detectada${NC}"
    PROFILE="gpu"
else
    echo -e "${YELLOW}⚠️  No se detectó GPU NVIDIA, usando CPU${NC}"
    PROFILE="cpu"
fi

# 4. Iniciar servicios
echo -e "${YELLOW}🐳 Paso 4: Iniciando servicios con perfil $PROFILE...${NC}"
docker compose --profile $PROFILE up -d

# Esperar a que los servicios estén listos
echo "⏳ Esperando a que Ollama esté listo..."
sleep 15

# Verificar que Ollama esté respondiendo
echo "🔍 Verificando conectividad con Ollama..."
for i in {1..10}; do
    if curl -s http://localhost:11434/api/version > /dev/null; then
        echo -e "${GREEN}✅ Ollama está funcionando${NC}"
        break
    else
        echo "Intento $i/10: Esperando a Ollama..."
        sleep 5
    fi
    
    if [ $i -eq 10 ]; then
        echo -e "${RED}❌ Ollama no responde después de 50 segundos${NC}"
        exit 1
    fi
done

# 5. Descargar modelos esenciales
echo -e "${YELLOW}📥 Paso 5: Descargando modelos esenciales...${NC}"

CONTAINER_NAME="ollama-dev-ai"
if [ "$PROFILE" = "gpu" ]; then
    CONTAINER_NAME="ollama-dev-ai"
fi

# Modelos básicos para empezar rápido
echo "📦 Descargando modelos básicos (rápidos)..."
docker exec $CONTAINER_NAME ollama pull llama3.2:1b
docker exec $CONTAINER_NAME ollama pull qwen2.5-coder:7b
docker exec $CONTAINER_NAME ollama pull deepseek-coder:6.7b
docker exec $CONTAINER_NAME ollama pull codellama:7b

# Modelo más grande opcional
echo -e "${YELLOW}¿Quieres descargar también modelos más grandes? (y/n)${NC}"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "📦 Descargando modelos adicionales..."
    docker exec $CONTAINER_NAME ollama pull llama3.1:8b
    # docker exec $CONTAINER_NAME ollama pull qwen2.5-coder:32b  # Comentado por tamaño
fi

# 6. Actualizar configuración de Continue
echo -e "${YELLOW}🔧 Paso 6: Actualizando configuración de Continue...${NC}"
if [ -f "update-continue-config.sh" ]; then
    chmod +x update-continue-config.sh
    ./update-continue-config.sh
    echo -e "${GREEN}✅ Configuración de Continue actualizada${NC}"
fi

# 7. Verificación final
echo -e "${BLUE}🎯 Verificación final:${NC}"
echo "📋 Contenedores activos:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "🧠 Modelos disponibles:"
docker exec $CONTAINER_NAME ollama list

echo ""
echo -e "${GREEN}🎉 ¡Configuración completada exitosamente!${NC}"
echo -e "${BLUE}🔗 URLs disponibles:${NC}"
echo "   • Ollama API: http://localhost:11434"
echo "   • Web UI: http://localhost:3000"
echo ""
echo -e "${YELLOW}📝 Próximos pasos:${NC}"
echo "1. Reinicia VS Code completamente"
echo "2. Abre Continue desde la barra lateral"
echo "3. Los modelos deberían aparecer automáticamente"
echo ""
echo -e "${GREEN}💡 Si tienes problemas, ejecuta: ./check-continue-status.sh${NC}"
