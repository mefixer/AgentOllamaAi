#!/bin/bash

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🌐 Configuración para acceso remoto del agente IA${NC}"
echo "==============================================="

# Obtener IP local
LOCAL_IP=$(ip route get 1 | grep -oP 'src \K\S+' 2>/dev/null || echo "No detectada")

echo -e "\n${GREEN}✅ Tu agente IA ahora es accesible desde:${NC}"
echo ""
echo -e "${YELLOW}🏠 Red Local (LAN):${NC}"
echo "  • https://$LOCAL_IP"
echo "  • http://$LOCAL_IP (redirige a HTTPS)"
echo ""
echo -e "${YELLOW}🖥️ Localmente:${NC}"
echo "  • https://localhost"
echo "  • https://ollamaai"
echo ""

# Verificar puertos abiertos
echo -e "${BLUE}🔌 Puertos disponibles:${NC}"
if netstat -tlnp 2>/dev/null | grep -q ":80 "; then
    echo -e "  • Puerto 80 (HTTP): ${GREEN}✅ Abierto${NC}"
else
    echo -e "  • Puerto 80 (HTTP): ${RED}❌ Cerrado${NC}"
fi

if netstat -tlnp 2>/dev/null | grep -q ":443 "; then
    echo -e "  • Puerto 443 (HTTPS): ${GREEN}✅ Abierto${NC}"
else
    echo -e "  • Puerto 443 (HTTPS): ${RED}❌ Cerrado${NC}"
fi

echo -e "\n${BLUE}📱 Para acceder desde otros dispositivos:${NC}"
echo "1. Conecta tu dispositivo a la misma red WiFi"
echo "2. Abre un navegador web"
echo "3. Ve a: https://$LOCAL_IP"
echo "4. Acepta el certificado auto-firmado (es seguro en tu red local)"
echo "5. Crea tu cuenta de usuario"

echo -e "\n${YELLOW}⚠️ Notas importantes:${NC}"
echo "• El certificado es auto-firmado (aparecerá como 'no seguro' pero es normal)"
echo "• Solo funciona en tu red local (WiFi doméstica/oficina)"
echo "• Para acceso desde internet, necesitas configuración adicional"

echo -e "\n${GREEN}🔧 Para acceso desde internet:${NC}"
echo "1. Necesitas un dominio público"
echo "2. Configurar router/firewall para abrir puertos 80 y 443"
echo "3. Usar certificados SSL válidos (Let's Encrypt)"
echo "4. O usar Cloudflare Tunnel (más seguro)"

echo -e "\n${BLUE}📊 Estado actual de servicios:${NC}"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(ollama|webui|nginx)"

echo -e "\n${GREEN}🎉 ¡Tu agente IA está listo para usar desde cualquier dispositivo en tu red!${NC}"
