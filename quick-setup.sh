#!/bin/bash

# Script automático para limpiar y configurar la IA local sin interacción
# Autor: Script generado para AgentOllamaAi

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔄 Configuración automática de IA local...${NC}"

# Función para verificar puerto
check_port() {
    local port=$1
    if ss -tulpn | grep ":$port " > /dev/null 2>&1; then
        return 0  # Puerto ocupado
    else
        return 1  # Puerto libre
    fi
}

# 1. Limpieza automática sin confirmación
echo -e "${YELLOW}🧹 Paso 1: Limpieza automática...${NC}"

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
    pkill -f "docker-proxy.*11434" 2>/dev/null || true
    sleep 3
fi

# Limpiar recursos Docker automáticamente
echo "Limpiando recursos Docker..."
docker network prune -f 2>/dev/null || true
docker volume prune -f 2>/dev/null || true

echo -e "${GREEN}✅ Limpieza completada${NC}"

# 2. Verificar que el puerto esté libre
echo -e "${YELLOW}🔍 Paso 2: Verificando puerto 11434...${NC}"
if check_port 11434; then
    echo -e "${RED}❌ El puerto 11434 aún está ocupado. Intentando una vez más...${NC}"
    pkill -f "docker.*11434" 2>/dev/null || true
    sleep 3
    if check_port 11434; then
        echo -e "${RED}❌ No se pudo liberar el puerto. Verifica manualmente.${NC}"
        exit 1
    fi
fi
echo -e "${GREEN}✅ Puerto 11434 libre${NC}"

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

# 5. Descargar solo modelos esenciales automáticamente
echo -e "${YELLOW}📥 Paso 5: Descargando modelos esenciales...${NC}"

CONTAINER_NAME="ollama-dev-ai"

# Solo modelos básicos y rápidos para empezar
echo "📦 Descargando modelos básicos..."
docker exec $CONTAINER_NAME ollama pull llama3.2:1b
docker exec $CONTAINER_NAME ollama pull qwen2.5-coder:7b
docker exec $CONTAINER_NAME ollama pull deepseek-coder:6.7b
docker exec $CONTAINER_NAME ollama pull codellama:7b
docker exec $CONTAINER_NAME ollama pull llama3.1:8b

# 6. Actualizar configuración de Continue
echo -e "${YELLOW}🔧 Paso 6: Actualizando configuración de Continue...${NC}"
if [ -f "update-continue-config.sh" ]; then
    chmod +x update-continue-config.sh
    ./update-continue-config.sh
    echo -e "${GREEN}✅ Configuración de Continue actualizada${NC}"
fi

# 7. Copiar configuración final
echo -e "${YELLOW}🔧 Paso 7: Aplicando configuración final...${NC}"
if [ -f "continue-config.json" ]; then
    mkdir -p "$HOME/.continue"
    cp "continue-config.json" "$HOME/.continue/config.json"
    echo -e "${GREEN}✅ Configuración copiada${NC}"
fi

# 8. Verificación final
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
