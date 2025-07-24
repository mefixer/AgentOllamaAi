#!/bin/bash

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🌍 Configuración para acceso desde INTERNET${NC}"
echo "============================================="

show_menu() {
    echo -e "\n${YELLOW}Selecciona cómo quieres exponer tu agente a internet:${NC}"
    echo "1. 🏠 Solo red local (actual) - RECOMENDADO para empezar"
    echo "2. 🌐 Internet con dominio propio + Let's Encrypt"
    echo "3. ☁️ Cloudflare Tunnel (más fácil y seguro)"
    echo "4. 🔧 Configuración manual avanzada"
    echo "5. ❌ Cancelar"
}

setup_domain() {
    echo -e "\n${GREEN}Configuración con dominio propio:${NC}"
    echo "Requisitos:"
    echo "• Un dominio registrado (ej: mi-ia.com)"
    echo "• Acceso al DNS del dominio"
    echo "• Router configurado para abrir puertos 80 y 443"
    echo "• IP pública estática (o DNS dinámico)"
    echo ""
    read -p "¿Tienes un dominio y quieres continuar? (y/N): " confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        read -p "Ingresa tu dominio (ej: mi-ia.com): " domain
        read -p "Ingresa tu email para Let's Encrypt: " email
        
        if [[ -n "$domain" && -n "$email" ]]; then
            echo -e "\n${GREEN}Configurando $domain...${NC}"
            ./setup-web-exposure.sh
        else
            echo -e "${RED}❌ Dominio y email son requeridos${NC}"
        fi
    fi
}

setup_cloudflare() {
    echo -e "\n${GREEN}Configuración con Cloudflare Tunnel:${NC}"
    echo "Ventajas:"
    echo "• No necesitas abrir puertos en el router"
    echo "• SSL automático"
    echo "• Protección DDoS incluida"
    echo "• Más seguro"
    echo ""
    echo "Pasos:"
    echo "1. Crea cuenta gratuita en cloudflare.com"
    echo "2. Agrega tu dominio (puede ser gratuito con subdominios .cf, .tk, etc.)"
    echo "3. Ve a Zero Trust → Networks → Tunnels"
    echo "4. Crea un tunnel y copia el token"
    echo ""
    read -p "¿Quieres continuar con Cloudflare? (y/N): " confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        ./setup-web-exposure.sh
    fi
}

setup_manual() {
    echo -e "\n${GREEN}Configuración manual avanzada:${NC}"
    echo "Esto requiere conocimientos técnicos avanzados:"
    echo ""
    echo "1. 🔧 Configurar router/firewall:"
    echo "   • Abrir puerto 80 (HTTP)"
    echo "   • Abrir puerto 443 (HTTPS)"
    echo "   • Redireccionar a tu IP interna: $(ip route get 1 | grep -oP 'src \K\S+')"
    echo ""
    echo "2. 🌐 DNS:"
    echo "   • Apuntar tu dominio a tu IP pública"
    echo "   • O usar servicios de DNS dinámico (No-IP, DuckDNS, etc.)"
    echo ""
    echo "3. 🔒 SSL:"
    echo "   • Usar Let's Encrypt con certbot"
    echo "   • O certificados comerciales"
    echo ""
    echo "4. 🛡️ Seguridad adicional:"
    echo "   • Configurar firewall"
    echo "   • Rate limiting"
    echo "   • Monitoreo de logs"
    echo ""
    echo -e "${YELLOW}¿Prefieres usar una de las opciones automáticas? (Recomendado)${NC}"
}

check_current_access() {
    LOCAL_IP=$(ip route get 1 | grep -oP 'src \K\S+')
    PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || echo "No detectada")
    
    echo -e "\n${BLUE}📊 Estado actual:${NC}"
    echo "• IP local: $LOCAL_IP"
    echo "• IP pública: $PUBLIC_IP"
    echo "• Acceso local: https://$LOCAL_IP ✅"
    
    # Verificar si los puertos están abiertos públicamente
    if timeout 5 curl -s --connect-timeout 3 http://$PUBLIC_IP >/dev/null 2>&1; then
        echo "• Acceso público: ✅ Disponible"
    else
        echo "• Acceso público: ❌ No disponible (puertos cerrados/firewall)"
    fi
}

main() {
    check_current_access
    
    while true; do
        show_menu
        read -p "Selecciona una opción (1-5): " choice
        
        case $choice in
            1)
                echo -e "\n${GREEN}✅ Tu configuración actual es perfecta para red local.${NC}"
                echo "Accede desde cualquier dispositivo en tu red: https://$(ip route get 1 | grep -oP 'src \K\S+')"
                break
                ;;
            2)
                setup_domain
                break
                ;;
            3)
                setup_cloudflare
                break
                ;;
            4)
                setup_manual
                ;;
            5)
                echo -e "${BLUE}Configuración cancelada.${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Opción inválida${NC}"
                ;;
        esac
    done
}

main
