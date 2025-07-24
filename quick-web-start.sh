#!/bin/bash

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🚀 Inicio Rápido - Agente IA en Internet${NC}"
echo "========================================"

echo -e "\n${GREEN}1. Configuración y exposición web:${NC}"
echo "./setup-web-exposure.sh"

echo -e "\n${GREEN}2. Configuración de seguridad:${NC}"
echo "./setup-security.sh"

echo -e "\n${GREEN}3. Iniciar con Nginx + SSL:${NC}"
echo "docker-compose -f docker-compose-web.yml --profile cpu up -d"

echo -e "\n${GREEN}4. Iniciar con Cloudflare:${NC}"
echo "docker-compose -f docker-compose-cloudflare.yml up -d"

echo -e "\n${GREEN}5. Ver logs:${NC}"
echo "docker-compose logs -f"

echo -e "\n${GREEN}6. Verificar estado:${NC}"
echo "docker ps"

echo -e "\n${YELLOW}📖 Para documentación completa, lee: EXPOSICION-WEB.md${NC}"
