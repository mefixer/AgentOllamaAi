#!/bin/bash

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🌐 Configuración para exponer agente IA a internet${NC}"
echo "=================================================="

# Función para mostrar menú
show_menu() {
    echo -e "\n${YELLOW}Selecciona el método de exposición:${NC}"
    echo "1. Nginx + SSL (Let's Encrypt) - Recomendado para VPS"
    echo "2. Cloudflare Tunnel - Más seguro, sin necesidad de abrir puertos"
    echo "3. Setup seguro con autenticación adicional"
    echo "4. Solo configuración local (desarrollo)"
    echo "5. Salir"
}

# Función para configurar Nginx + SSL
setup_nginx_ssl() {
    echo -e "\n${GREEN}Configurando Nginx + SSL...${NC}"
    
    # Solicitar dominio
    read -p "Ingresa tu dominio (ej: mi-ia.com): " DOMAIN
    read -p "Ingresa tu email para SSL: " EMAIL
    
    if [[ -z "$DOMAIN" || -z "$EMAIL" ]]; then
        echo -e "${RED}❌ Dominio y email son requeridos${NC}"
        return 1
    fi
    
    # Reemplazar dominio en nginx.conf
    sed -i "s/your-domain.com/$DOMAIN/g" nginx/nginx.conf
    sed -i "s/your-email@domain.com/$EMAIL/g" docker-compose-web.yml
    
    # Crear directorio SSL
    mkdir -p nginx/ssl nginx/webroot
    
    # Generar clave secreta
    WEBUI_SECRET=$(openssl rand -base64 32)
    JWT_SECRET=$(openssl rand -base64 32)
    
    # Crear archivo .env
    cat > .env << EOF
WEBUI_SECRET_KEY=$WEBUI_SECRET
WEBUI_JWT_SECRET_KEY=$JWT_SECRET
DOMAIN=$DOMAIN
EMAIL=$EMAIL
EOF
    
    echo -e "${GREEN}✅ Configuración completada${NC}"
    echo -e "${YELLOW}Para iniciar:${NC}"
    echo "1. Asegúrate de que tu dominio apunte a esta IP"
    echo "2. Ejecuta: docker-compose -f docker-compose-web.yml --profile cpu up -d"
    echo "3. Para SSL: docker-compose -f docker-compose-web.yml --profile ssl run --rm certbot"
}

# Función para configurar Cloudflare Tunnel
setup_cloudflare() {
    echo -e "\n${GREEN}Configurando Cloudflare Tunnel...${NC}"
    echo "Necesitarás una cuenta de Cloudflare y crear un tunnel."
    echo ""
    echo "Pasos:"
    echo "1. Ve a https://dash.cloudflare.com/"
    echo "2. Selecciona tu sitio -> Zero Trust -> Networks -> Tunnels"
    echo "3. Crea un nuevo tunnel y copia el token"
    echo ""
    
    read -p "Ingresa tu Cloudflare Tunnel Token: " CF_TOKEN
    
    if [[ -z "$CF_TOKEN" ]]; then
        echo -e "${RED}❌ Token de Cloudflare requerido${NC}"
        return 1
    fi
    
    # Generar claves secretas
    WEBUI_SECRET=$(openssl rand -base64 32)
    JWT_SECRET=$(openssl rand -base64 32)
    
    # Crear archivo .env
    cat > .env << EOF
CLOUDFLARE_TUNNEL_TOKEN=$CF_TOKEN
WEBUI_SECRET_KEY=$WEBUI_SECRET
WEBUI_JWT_SECRET_KEY=$JWT_SECRET
EOF
    
    echo -e "${GREEN}✅ Configuración de Cloudflare completada${NC}"
    echo -e "${YELLOW}Para iniciar:${NC}"
    echo "docker-compose -f docker-compose-cloudflare.yml up -d"
}

# Función para setup seguro
setup_secure() {
    echo -e "\n${GREEN}Configurando setup seguro con autenticación...${NC}"
    
    read -p "Ingresa tu dominio: " DOMAIN
    read -p "¿Permitir registro público? (y/N): " ALLOW_SIGNUP
    
    # Configurar signup
    if [[ "$ALLOW_SIGNUP" =~ ^[Yy]$ ]]; then
        ENABLE_SIGNUP="true"
    else
        ENABLE_SIGNUP="false"
    fi
    
    # Generar claves
    WEBUI_SECRET=$(openssl rand -base64 32)
    JWT_SECRET=$(openssl rand -base64 32)
    
    cat > .env << EOF
WEBUI_SECRET_KEY=$WEBUI_SECRET
WEBUI_JWT_SECRET_KEY=$JWT_SECRET
ENABLE_SIGNUP=$ENABLE_SIGNUP
DOMAIN=$DOMAIN
EOF
    
    # Crear configuración de Authelia (básica)
    mkdir -p authelia
    cat > authelia/configuration.yml << 'EOF'
server:
  host: 0.0.0.0
  port: 9091

log:
  level: warn

jwt_secret: change-this-jwt-secret

default_redirection_url: https://your-domain.com

authentication_backend:
  file:
    path: /config/users_database.yml

access_control:
  default_policy: deny
  rules:
    - domain: your-domain.com
      policy: two_factor

session:
  name: authelia_session
  secret: change-this-session-secret
  expiration: 3600
  inactivity: 300

regulation:
  max_retries: 3
  find_time: 120
  ban_time: 300

storage:
  local:
    path: /config/db.sqlite3

notifier:
  filesystem:
    filename: /config/notification.txt
EOF
    
    echo -e "${GREEN}✅ Configuración segura completada${NC}"
    echo -e "${YELLOW}Para iniciar: docker-compose -f docker-compose-secure.yml up -d${NC}"
}

# Función para configuración local
setup_local() {
    echo -e "\n${GREEN}Manteniendo configuración local...${NC}"
    echo "Tu agente seguirá disponible solo localmente en:"
    echo "- Ollama: http://localhost:11434"
    echo "- WebUI: http://localhost:3001"
    
    echo -e "${YELLOW}Para iniciar: docker-compose --profile cpu up -d${NC}"
}

# Función principal
main() {
    # Verificar Docker
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker no está instalado${NC}"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        echo -e "${RED}❌ Docker Compose no está instalado${NC}"
        exit 1
    fi
    
    while true; do
        show_menu
        read -p "Selecciona una opción (1-5): " choice
        
        case $choice in
            1)
                setup_nginx_ssl
                break
                ;;
            2)
                setup_cloudflare
                break
                ;;
            3)
                setup_secure
                break
                ;;
            4)
                setup_local
                break
                ;;
            5)
                echo -e "${BLUE}¡Hasta luego!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Opción inválida${NC}"
                ;;
        esac
    done
}

# Ejecutar función principal
main
