#!/bin/bash

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🔐 Creación de usuario para Open WebUI${NC}"
echo "======================================"

echo -e "\n${YELLOW}Ahora puedes acceder a tu agente IA en:${NC}"
echo "URL: https://ollamaai"
echo ""
echo -e "${GREEN}Como es una instalación limpia, deberías poder:${NC}"
echo "1. Ver una página de registro/login"
echo "2. Crear una cuenta nueva (el primer usuario será admin)"
echo "3. Usar las siguientes credenciales de ejemplo:"
echo "   Email: admin@local.com"
echo "   Contraseña: admin123"
echo ""
echo -e "${YELLOW}O puedes usar tus propias credenciales.${NC}"
echo ""
echo -e "${BLUE}Estado de los servicios:${NC}"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(ollama|webui|nginx)"

echo -e "\n${GREEN}Para monitorear logs:${NC}"
echo "docker logs -f open-webui-public"
echo "docker logs -f ai-nginx-proxy"

echo -e "\n${YELLOW}¡Tu agente IA está listo para usar!${NC}"
