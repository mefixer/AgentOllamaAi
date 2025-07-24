#!/bin/bash

# Script para limpiar completamente la configuración anterior de Ollama/Continue
# Autor: Script generado para AgentOllamaAi

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧹 Limpieza completa del sistema AI local...${NC}"

# Función para mostrar procesos que usan el puerto
show_port_usage() {
    local port=$1
    echo -e "${YELLOW}🔍 Procesos usando el puerto $port:${NC}"
    sudo netstat -tlnp | grep ":$port " || echo "Puerto libre"
    echo ""
}

# Función para verificar puerto
check_port() {
    local port=$1
    if ss -tulpn | grep ":$port " > /dev/null 2>&1; then
        return 0  # Puerto ocupado
    else
        return 1  # Puerto libre
    fi
}

# Mostrar estado inicial
echo -e "${YELLOW}📊 Estado inicial de los puertos:${NC}"
show_port_usage 11434
show_port_usage 3001

# 1. Detener servicios con Docker Compose
echo -e "${YELLOW}1. Deteniendo servicios con Docker Compose...${NC}"
if [ -f "docker-compose.yml" ]; then
    docker-compose down --remove-orphans 2>/dev/null || true
    docker compose down --remove-orphans 2>/dev/null || true
    echo -e "${GREEN}✅ Servicios Docker Compose detenidos${NC}"
else
    echo -e "${YELLOW}⚠️  No se encontró docker-compose.yml${NC}"
fi

# 2. Detener contenedores relacionados
echo -e "${YELLOW}2. Deteniendo contenedores relacionados con Ollama...${NC}"
# Obtener IDs de contenedores relacionados
OLLAMA_CONTAINERS=$(docker ps -q --filter "name=ollama" 2>/dev/null || true)
WEBUI_CONTAINERS=$(docker ps -q --filter "name=open-webui" 2>/dev/null || true)
AI_CONTAINERS=$(docker ps -q --filter "name=*ai*" 2>/dev/null || true)

# Detener contenedores
if [ ! -z "$OLLAMA_CONTAINERS" ]; then
    echo "Deteniendo contenedores Ollama..."
    docker stop $OLLAMA_CONTAINERS
fi

if [ ! -z "$WEBUI_CONTAINERS" ]; then
    echo "Deteniendo contenedores Open WebUI..."
    docker stop $WEBUI_CONTAINERS
fi

if [ ! -z "$AI_CONTAINERS" ]; then
    echo "Deteniendo otros contenedores AI..."
    docker stop $AI_CONTAINERS
fi

echo -e "${GREEN}✅ Contenedores detenidos${NC}"

# 3. Eliminar contenedores
echo -e "${YELLOW}3. Eliminando contenedores...${NC}"
# Eliminar contenedores detenidos relacionados
docker rm $(docker ps -aq --filter "name=ollama") 2>/dev/null || true
docker rm $(docker ps -aq --filter "name=open-webui") 2>/dev/null || true
docker rm $(docker ps -aq --filter "name=*ai*") 2>/dev/null || true

echo -e "${GREEN}✅ Contenedores eliminados${NC}"

# 4. Matar procesos que usen el puerto 11434
# Liberar puertos 11434 y 3001 de forma agresiva
echo "Liberando puertos 11434 y 3001..."
if check_port 11434; then
    echo "Puerto 11434 ocupado, liberando..."
    pkill -f "docker-proxy.*11434" 2>/dev/null || true
fi

if check_port 3001; then
    echo "Puerto 3001 ocupado, liberando..."
    pkill -f "docker-proxy.*3001" 2>/dev/null || true
    # También intentar matar procesos que usen el puerto 3001
    lsof -ti :3001 | xargs kill -9 2>/dev/null || true
fi

sleep 3

# 5. Limpiar redes Docker
echo -e "${YELLOW}5. Limpiando redes Docker...${NC}"
docker network prune -f
echo -e "${GREEN}✅ Redes limpiadas${NC}"

# 6. Limpiar volúmenes huérfanos
echo -e "${YELLOW}6. Limpiando volúmenes huérfanos...${NC}"
docker volume prune -f
echo -e "${GREEN}✅ Volúmenes limpiados${NC}"

# 7. Limpiar imágenes no utilizadas (opcional)
echo -e "${YELLOW}7. ¿Quieres limpiar también las imágenes Docker no utilizadas? (y/n)${NC}"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    docker image prune -f
    echo -e "${GREEN}✅ Imágenes limpiadas${NC}"
else
    echo -e "${YELLOW}⏭️  Saltando limpieza de imágenes${NC}"
fi

# 8. Reiniciar Docker daemon (si es necesario)
echo -e "${YELLOW}8. ¿Necesitas reiniciar el servicio Docker? (y/n)${NC}"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "Reiniciando Docker daemon..."
    sudo systemctl restart docker
    sleep 5
    echo -e "${GREEN}✅ Docker reiniciado${NC}"
fi

# Verificación final
echo -e "${BLUE}🔍 Verificación final:${NC}"
show_port_usage 11434
show_port_usage 3001

# Mostrar contenedores activos
echo -e "${YELLOW}📋 Contenedores activos:${NC}"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo -e "${GREEN}🎉 ¡Limpieza completa terminada!${NC}"
echo -e "${BLUE}💡 Ahora puedes ejecutar './setup-ai.sh' para una configuración limpia${NC}"
