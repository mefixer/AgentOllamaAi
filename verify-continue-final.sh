#!/bin/bash

# Script de verificación final para Continue
# Autor: Script generado para AgentOllamaAi

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 Verificación final de Continue...${NC}"

# 1. Verificar archivos de configuración
echo -e "${YELLOW}1. Verificando archivos de configuración...${NC}"
CONTINUE_DIR="$HOME/.continue"

if [ -f "$CONTINUE_DIR/config.json" ]; then
    MODELS_JSON=$(jq -r '.models | length' "$CONTINUE_DIR/config.json" 2>/dev/null || echo "0")
    echo -e "${GREEN}✅ config.json: $MODELS_JSON modelos${NC}"
else
    echo -e "${RED}❌ config.json no encontrado${NC}"
fi

if [ -f "$CONTINUE_DIR/config.yaml" ]; then
    MODELS_YAML=$(grep -c "provider: ollama" "$CONTINUE_DIR/config.yaml" 2>/dev/null || echo "0")
    echo -e "${GREEN}✅ config.yaml: $MODELS_YAML modelos${NC}"
else
    echo -e "${RED}❌ config.yaml no encontrado${NC}"
fi

# 2. Verificar Ollama
echo -e "${YELLOW}2. Verificando conexión Ollama...${NC}"
if curl -s http://localhost:11434/api/version > /dev/null; then
    VERSION=$(curl -s http://localhost:11434/api/version | jq -r '.version')
    echo -e "${GREEN}✅ Ollama v$VERSION funcionando${NC}"
    
    # Listar modelos disponibles
    AVAILABLE_MODELS=$(curl -s http://localhost:11434/api/tags | jq -r '.models[].name' | wc -l)
    echo -e "${GREEN}✅ $AVAILABLE_MODELS modelos disponibles en Ollama${NC}"
else
    echo -e "${RED}❌ Ollama no responde${NC}"
fi

# 3. Probar modelo principal
echo -e "${YELLOW}3. Probando modelo principal...${NC}"
RESPONSE=$(curl -s -X POST http://localhost:11434/api/generate \
    -H "Content-Type: application/json" \
    -d '{"model": "qwen2.5-coder:7b", "prompt": "Hola", "stream": false}' | \
    jq -r '.response' 2>/dev/null || echo "Error")

if [ "$RESPONSE" != "Error" ] && [ ! -z "$RESPONSE" ]; then
    echo -e "${GREEN}✅ Modelo principal funciona correctamente${NC}"
else
    echo -e "${RED}❌ Error al probar modelo principal${NC}"
fi

# 4. Verificar permisos
echo -e "${YELLOW}4. Verificando permisos...${NC}"
if [ -r "$CONTINUE_DIR/config.json" ] && [ -r "$CONTINUE_DIR/config.yaml" ]; then
    echo -e "${GREEN}✅ Permisos correctos${NC}"
else
    echo -e "${RED}❌ Problemas de permisos${NC}"
fi

# 5. Estado del directorio
echo -e "${YELLOW}5. Estado del directorio Continue...${NC}"
echo -e "${BLUE}Archivos en ~/.continue/:${NC}"
ls -la "$CONTINUE_DIR/" | grep -E "\.(json|yaml|ts)$" | while read line; do
    echo -e "  ${GREEN}→${NC} $line"
done

echo ""
echo -e "${BLUE}🎯 RESULTADO FINAL:${NC}"

if [ "$MODELS_JSON" -gt 0 ] && [ "$MODELS_YAML" -gt 0 ] && [ "$AVAILABLE_MODELS" -gt 0 ]; then
    echo -e "${GREEN}✅ TODO CONFIGURADO CORRECTAMENTE${NC}"
    echo -e "${YELLOW}📋 Pasos finales:${NC}"
    echo -e "1. ${RED}CIERRA VS Code COMPLETAMENTE${NC}"
    echo -e "2. ${GREEN}Abre VS Code nuevamente${NC}"
    echo -e "3. ${GREEN}Abre Continue (Ctrl+Shift+P → 'Continue')${NC}"
    echo -e "4. ${GREEN}Los modelos deberían aparecer ahora${NC}"
    echo ""
    echo -e "${BLUE}📋 Modelos disponibles:${NC}"
    echo -e "• Qwen 2.5 Coder 7B (Programación)"
    echo -e "• DeepSeek Coder 6.7B (Código)" 
    echo -e "• CodeLlama 7B (Desarrollo)"
    echo -e "• Llama 3.1 8B (General)"
    echo -e "• Llama 3.2 1B (Rápido)"
else
    echo -e "${RED}❌ AÚN HAY PROBLEMAS${NC}"
    echo -e "${YELLOW}Ejecuta: ./fix-continue-definitive.sh${NC}"
fi
