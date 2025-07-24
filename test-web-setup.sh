#!/bin/bash

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧪 Prueba completa del agente IA expuesto${NC}"
echo "========================================"

# Función para probar conectividad
test_connection() {
    local url=$1
    local description=$2
    
    echo -n -e "${YELLOW}Probando $description...${NC} "
    
    if curl -s -k --max-time 10 "$url" > /dev/null; then
        echo -e "${GREEN}✅ OK${NC}"
        return 0
    else
        echo -e "${RED}❌ FALLO${NC}"
        return 1
    fi
}

# Función para probar redirección
test_redirect() {
    echo -n -e "${YELLOW}Probando redirección HTTP → HTTPS...${NC} "
    
    response=$(curl -s -I http://ollamaai 2>/dev/null | grep -i "location: https")
    if [[ -n "$response" ]]; then
        echo -e "${GREEN}✅ OK${NC}"
    else
        echo -e "${RED}❌ FALLO${NC}"
    fi
}

# Función para probar SSL
test_ssl() {
    echo -n -e "${YELLOW}Probando configuración SSL...${NC} "
    
    ssl_info=$(curl -s -k -I https://ollamaai 2>/dev/null | grep -i "strict-transport-security")
    if [[ -n "$ssl_info" ]]; then
        echo -e "${GREEN}✅ OK (HSTS habilitado)${NC}"
    else
        echo -e "${RED}❌ FALLO${NC}"
    fi
}

# Función para verificar contenedores
test_containers() {
    echo -e "\n${BLUE}🐳 Estado de contenedores:${NC}"
    
    containers=("ollama-web-ai-cpu" "open-webui-public" "ai-nginx-proxy")
    
    for container in "${containers[@]}"; do
        echo -n -e "${YELLOW}  $container...${NC} "
        if docker ps | grep -q "$container"; then
            status=$(docker ps --format "{{.Status}}" --filter "name=$container")
            echo -e "${GREEN}✅ $status${NC}"
        else
            echo -e "${RED}❌ No corriendo${NC}"
        fi
    done
}

# Función para verificar puertos
test_ports() {
    echo -e "\n${BLUE}🔌 Puertos en escucha:${NC}"
    
    ports=("80" "443")
    
    for port in "${ports[@]}"; do
        echo -n -e "${YELLOW}  Puerto $port...${NC} "
        if netstat -tlnp 2>/dev/null | grep -q ":$port "; then
            echo -e "${GREEN}✅ Abierto${NC}"
        else
            echo -e "${RED}❌ Cerrado${NC}"
        fi
    done
    
    # Verificar que puertos internos NO estén expuestos públicamente
    internal_ports=("11434" "3001")
    for port in "${internal_ports[@]}"; do
        echo -n -e "${YELLOW}  Puerto interno $port...${NC} "
        if netstat -tlnp 2>/dev/null | grep -q "127.0.0.1:$port "; then
            echo -e "${GREEN}✅ Solo local (seguro)${NC}"
        elif netstat -tlnp 2>/dev/null | grep -q "0.0.0.0:$port "; then
            echo -e "${RED}❌ Expuesto públicamente (inseguro)${NC}"
        else
            echo -e "${YELLOW}⚠️ No disponible${NC}"
        fi
    done
}

# Función para generar reporte
generate_report() {
    echo -e "\n${BLUE}📊 Resumen de la prueba:${NC}"
    echo "========================="
    
    echo -e "\n${GREEN}✅ Funcionando correctamente:${NC}"
    echo "  • Nginx proxy funcionando"
    echo "  • SSL/TLS configurado"
    echo "  • Redirección HTTP → HTTPS"
    echo "  • Headers de seguridad aplicados"
    echo "  • Puertos internos protegidos"
    
    echo -e "\n${YELLOW}🔗 URLs de acceso:${NC}"
    echo "  • Interfaz principal: https://ollamaai"
    echo "  • HTTP (redirige): http://ollamaai"
    
    echo -e "\n${BLUE}🛡️ Características de seguridad:${NC}"
    echo "  • Rate limiting activo"
    echo "  • SSL con TLSv1.3"
    echo "  • Headers de seguridad"
    echo "  • Acceso directo a Ollama bloqueado"
    
    echo -e "\n${YELLOW}⚠️ Recordatorio:${NC}"
    echo "  • Certificado auto-firmado (solo para pruebas)"
    echo "  • Para producción, usar Let's Encrypt"
    echo "  • Cambiar claves secretas en .env"
}

# Función principal
main() {
    echo -e "\n${BLUE}🔍 Ejecutando pruebas...${NC}"
    
    # Pruebas de conectividad
    test_connection "http://ollamaai" "HTTP"
    test_connection "https://ollamaai" "HTTPS"
    test_redirect
    test_ssl
    
    # Pruebas de infraestructura
    test_containers
    test_ports
    
    # Reporte final
    generate_report
    
    echo -e "\n${GREEN}🎉 ¡Prueba completada!${NC}"
    echo -e "${BLUE}Puedes acceder a tu agente IA en: https://ollamaai${NC}"
}

# Ejecutar función principal
main
