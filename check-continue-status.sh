#!/bin/bash

# Script para verificar el estado de Continue y los agentes
# Autor: Script generado para AgentOllamaAi

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Verificando configuración de Continue...${NC}"

# Verificar directorio de Continue
CONTINUE_DIR="$HOME/.continue"
if [ -d "$CONTINUE_DIR" ]; then
    echo -e "${GREEN}✅ Directorio de Continue encontrado: $CONTINUE_DIR${NC}"
    
    # Verificar archivo de configuración
    CONFIG_FILE="$CONTINUE_DIR/config.json"
    if [ -f "$CONFIG_FILE" ]; then
        echo -e "${GREEN}✅ Archivo de configuración encontrado${NC}"
        
        # Verificar sección de agentes
        if grep -q '"agents"' "$CONFIG_FILE"; then
            echo -e "${GREEN}✅ Sección de agentes configurada${NC}"
            
            # Mostrar agentes configurados
            echo -e "${BLUE}📋 Agentes configurados:${NC}"
            grep -A 4 '"title":' "$CONFIG_FILE" | grep '"title":' | sed 's/.*"title": "\(.*\)".*/  • \1/'
        else
            echo -e "${RED}❌ No se encontró la sección de agentes${NC}"
        fi
        
        # Verificar modelos
        if grep -q '"models"' "$CONFIG_FILE"; then
            echo -e "${GREEN}✅ Sección de modelos configurada${NC}"
            
            echo -e "${BLUE}📋 Modelos configurados:${NC}"
            grep -A 4 '"title":' "$CONFIG_FILE" | grep '"title":' | sed 's/.*"title": "\(.*\)".*/  • \1/'
        else
            echo -e "${RED}❌ No se encontró la sección de modelos${NC}"
        fi
    else
        echo -e "${RED}❌ No se encontró el archivo de configuración${NC}"
    fi
else
    echo -e "${RED}❌ Directorio de Continue no encontrado${NC}"
fi

echo ""

# Verificar conexión con Ollama
echo -e "${BLUE}🔍 Verificando conexión con Ollama...${NC}"
if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Ollama está funcionando correctamente${NC}"
    
    # Contar modelos disponibles
    MODEL_COUNT=$(curl -s http://localhost:11434/api/tags | jq -r '.models | length')
    echo -e "${GREEN}📊 Modelos disponibles en Ollama: $MODEL_COUNT${NC}"
else
    echo -e "${RED}❌ No se puede conectar con Ollama${NC}"
    echo -e "${YELLOW}💡 Inicia los contenedores con:${NC}"
    echo -e "   docker-compose --profile gpu up -d"
    echo -e "   o"
    echo -e "   docker-compose --profile cpu up -d"
fi

echo ""

# Verificar contenedores Docker
echo -e "${BLUE}🐳 Estado de contenedores Docker:${NC}"
if command -v docker &> /dev/null; then
    OLLAMA_RUNNING=$(docker ps --filter "name=ollama" --format "table {{.Names}}\t{{.Status}}" | grep -v NAMES || true)
    if [ -n "$OLLAMA_RUNNING" ]; then
        echo -e "${GREEN}✅ Contenedores Ollama ejecutándose:${NC}"
        echo "$OLLAMA_RUNNING"
    else
        echo -e "${RED}❌ No hay contenedores Ollama ejecutándose${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Docker no está disponible${NC}"
fi

echo ""
echo -e "${BLUE}📝 Para usar los agentes:${NC}"
echo -e "1. ${YELLOW}Reinicia VS Code${NC} si acabas de hacer cambios"
echo -e "2. Abre Continue con ${YELLOW}Ctrl+Shift+P${NC} → 'Continue'"
echo -e "3. En la pestaña de Continue, busca la sección de ${YELLOW}'Agents'${NC}"
echo -e "4. Selecciona el agente que quieras usar"
echo ""
echo -e "${GREEN}🎉 ¡Los agentes deberían aparecer ahora en Continue!${NC}"
