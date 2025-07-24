#!/bin/bash

# Script para reiniciar Continue y verificar configuración
# Autor: Script generado para AgentOllamaAi

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔄 Reiniciando Continue...${NC}"

# Verificar que Ollama esté funcionando
echo -e "${YELLOW}📡 Verificando conexión con Ollama...${NC}"
if curl -s http://localhost:11434/api/tags > /dev/null; then
    echo -e "${GREEN}✅ Ollama está funcionando${NC}"
else
    echo -e "${RED}❌ Ollama no está disponible. Verifica que esté corriendo.${NC}"
    exit 1
fi

# Verificar configuración JSON
echo -e "${YELLOW}🔍 Validando configuración JSON...${NC}"
if python3 -m json.tool ~/.continue/config.json > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Configuración JSON válida${NC}"
else
    echo -e "${RED}❌ Error en configuración JSON${NC}"
    exit 1
fi

# Mostrar modelos configurados
echo -e "${YELLOW}📋 Modelos configurados en Continue:${NC}"
python3 -c "
import json
with open('/home/mauriciogarcia/.continue/config.json', 'r') as f:
    config = json.load(f)
for model in config['models']:
    print(f'  • {model[\"title\"]} ({model[\"model\"]})')
"

echo ""
echo -e "${GREEN}🎉 Continue está configurado correctamente!${NC}"
echo ""
echo -e "${BLUE}📝 Próximos pasos:${NC}"
echo "1. En VS Code, presiona Ctrl+Shift+P"
echo "2. Escribe 'Developer: Reload Window' y presiona Enter"
echo "3. O simplemente cierra y abre VS Code nuevamente"
echo "4. Abre Continue desde la barra lateral o con Ctrl+Shift+P -> 'Continue'"
echo ""
echo -e "${YELLOW}💡 Si el error persiste:${NC}"
echo "• Verifica que la extensión Continue esté actualizada"
echo "• Reinicia VS Code completamente"
echo "• Revisa la consola de desarrollador de VS Code (F12)"
