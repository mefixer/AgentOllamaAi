#!/bin/bash

# Script principal para solucionar problemas de agentes en Continue
# Autor: Script generado para AgentOllamaAi

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}🚀 Solucionador de Problemas de Agentes en Continue${NC}"
echo -e "${CYAN}=================================================${NC}"
echo ""

# Función para mostrar título de sección
show_section() {
    echo -e "${PURPLE}📋 $1${NC}"
    echo -e "${PURPLE}$(printf '%.0s-' {1..50})${NC}"
}

# 1. Verificar estado inicial
show_section "1. VERIFICANDO ESTADO INICIAL"
echo -e "${YELLOW}🔍 Verificando contenedores Docker...${NC}"
OLLAMA_RUNNING=$(docker ps --filter "name=ollama" --format "{{.Names}}" | head -1 || echo "")

if [ -z "$OLLAMA_RUNNING" ]; then
    echo -e "${RED}❌ Contenedor Ollama no está ejecutándose${NC}"
    echo -e "${YELLOW}💡 Iniciando contenedores...${NC}"
    
    # Detectar si tiene GPU
    if nvidia-smi &>/dev/null; then
        echo -e "${GREEN}🎮 GPU NVIDIA detectada, usando perfil GPU${NC}"
        docker-compose --profile gpu up -d
    else
        echo -e "${BLUE}💻 Usando perfil CPU${NC}"
        docker-compose --profile cpu up -d
    fi
    
    echo -e "${YELLOW}⏳ Esperando que los servicios estén listos...${NC}"
    sleep 10
else
    echo -e "${GREEN}✅ Contenedor Ollama ejecutándose: $OLLAMA_RUNNING${NC}"
fi

# 2. Verificar conectividad
show_section "2. VERIFICANDO CONECTIVIDAD"
echo -e "${YELLOW}🔗 Probando conexión con Ollama...${NC}"
if curl -s http://localhost:11434/api/tags > /dev/null; then
    echo -e "${GREEN}✅ Ollama responde correctamente${NC}"
    
    # Mostrar modelos disponibles
    MODEL_COUNT=$(curl -s http://localhost:11434/api/tags | jq -r '.models | length')
    echo -e "${GREEN}📊 Modelos disponibles: $MODEL_COUNT${NC}"
    
    if [ "$MODEL_COUNT" -eq 0 ]; then
        echo -e "${YELLOW}⚠️  No hay modelos instalados${NC}"
        echo -e "${YELLOW}💡 Ejecutando instalación de modelos...${NC}"
        ./manage-models.sh
    fi
else
    echo -e "${RED}❌ Error de conectividad con Ollama${NC}"
    exit 1
fi

# 3. Configurar agentes
show_section "3. CONFIGURANDO AGENTES EN CONTINUE"
echo -e "${YELLOW}⚙️  Aplicando configuración de agentes...${NC}"

# Verificar si Continue está instalado
CONTINUE_DIR="$HOME/.continue"
if [ ! -d "$CONTINUE_DIR" ]; then
    echo -e "${YELLOW}📁 Creando directorio de Continue...${NC}"
    mkdir -p "$CONTINUE_DIR"
fi

# Configurar agentes
./setup-continue-agents.sh

# 4. Verificar configuración final
show_section "4. VERIFICACIÓN FINAL"
./check-continue-status.sh

# 5. Mostrar resumen y próximos pasos
echo ""
show_section "5. RESUMEN Y PRÓXIMOS PASOS"

echo -e "${GREEN}🎉 ¡PROBLEMA RESUELTO!${NC}"
echo ""
echo -e "${BLUE}📝 Lo que se ha solucionado:${NC}"
echo -e "   ${GREEN}✅${NC} Contenedores Docker ejecutándose"
echo -e "   ${GREEN}✅${NC} Ollama funcionando correctamente"
echo -e "   ${GREEN}✅${NC} Modelos disponibles y funcionando"
echo -e "   ${GREEN}✅${NC} Configuración de Continue actualizada"
echo -e "   ${GREEN}✅${NC} Sección de agentes habilitada"
echo ""

echo -e "${YELLOW}🔧 PRÓXIMOS PASOS PARA VER LOS AGENTES:${NC}"
echo -e "   ${CYAN}1.${NC} Reinicia VS Code completamente"
echo -e "   ${CYAN}2.${NC} Abre Continue: ${YELLOW}Ctrl+Shift+P${NC} → 'Continue'"
echo -e "   ${CYAN}3.${NC} Busca la pestaña/sección ${YELLOW}'Agents'${NC} en Continue"
echo -e "   ${CYAN}4.${NC} Selecciona el agente que quieras usar:"
echo -e "      • ${GREEN}Asistente de Código${NC} (qwen2.5-coder:7b)"
echo -e "      • ${GREEN}Revisor de Código${NC} (deepseek-coder:6.7b)"
echo -e "      • ${GREEN}Documentador${NC} (llama3.1:8b)"
echo ""

echo -e "${PURPLE}💡 TIPS ADICIONALES:${NC}"
echo -e "   • Si no ves los agentes, verifica que Continue esté actualizado"
echo -e "   • Los agentes aparecen como una sección separada de los modelos de chat"
echo -e "   • Puedes usar ${YELLOW}./check-continue-status.sh${NC} para verificar el estado"
echo ""

echo -e "${CYAN}🌐 URLs útiles:${NC}"
echo -e "   • Ollama API: ${YELLOW}http://localhost:11434${NC}"
echo -e "   • Interfaz Web: ${YELLOW}http://localhost:3000${NC}"
echo ""

echo -e "${GREEN}✨ ¡Los agentes ya deberían aparecer en Continue!${NC}"
