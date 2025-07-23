#!/bin/bash

# Script para configurar agentes en Continue
# Autor: Script generado para AgentOllamaAi

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Configurando agentes en Continue...${NC}"

# Determinar la ruta de configuración de Continue
CONTINUE_CONFIG_DIR=""

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    CONTINUE_CONFIG_DIR="$HOME/.continue"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    CONTINUE_CONFIG_DIR="$HOME/.continue"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    CONTINUE_CONFIG_DIR="$APPDATA/continue"
fi

if [ -z "$CONTINUE_CONFIG_DIR" ]; then
    echo -e "${RED}❌ No se pudo determinar la ubicación de configuración de Continue${NC}"
    exit 1
fi

# Crear directorio si no existe
mkdir -p "$CONTINUE_CONFIG_DIR"

# Copiar configuración
echo -e "${YELLOW}📁 Copiando configuración a: $CONTINUE_CONFIG_DIR${NC}"
cp "./continue-config.json" "$CONTINUE_CONFIG_DIR/config.json"

# Verificar que Ollama esté funcionando
echo -e "${YELLOW}🔍 Verificando conexión con Ollama...${NC}"
if curl -s http://localhost:11434/api/tags > /dev/null; then
    echo -e "${GREEN}✅ Ollama está funcionando correctamente${NC}"
    
    # Listar modelos disponibles
    echo -e "${BLUE}📋 Modelos disponibles:${NC}"
    curl -s http://localhost:11434/api/tags | jq -r '.models[].name' | while read -r model; do
        echo -e "  ${GREEN}• $model${NC}"
    done
else
    echo -e "${RED}❌ No se puede conectar con Ollama en localhost:11434${NC}"
    echo -e "${YELLOW}💡 Asegúrate de que el contenedor esté ejecutándose:${NC}"
    echo -e "   docker-compose --profile gpu up -d ollama open-webui-gpu"
    echo -e "   o"
    echo -e "   docker-compose --profile cpu up -d ollama-cpu open-webui"
fi

echo ""
echo -e "${GREEN}🎉 Configuración completada!${NC}"
echo -e "${BLUE}📝 Próximos pasos:${NC}"
echo -e "1. Reinicia VS Code"
echo -e "2. Abre Continue (Ctrl+Shift+P -> 'Continue')"
echo -e "3. Los agentes aparecerán en la pestaña de Continue"
echo ""
echo -e "${YELLOW}💡 Agentes configurados:${NC}"
echo -e "• Asistente de Código (qwen2.5-coder:7b)"
echo -e "• Revisor de Código (deepseek-coder:6.7b)" 
echo -e "• Documentador (llama3.1:8b)"
