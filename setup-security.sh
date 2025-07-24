#!/bin/bash

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔒 Configuración de seguridad para agente IA${NC}"
echo "=============================================="

# Función para configurar firewall básico
setup_firewall() {
    echo -e "\n${GREEN}Configurando firewall...${NC}"
    
    # Verificar si ufw está instalado
    if ! command -v ufw &> /dev/null; then
        echo -e "${YELLOW}Instalando ufw...${NC}"
        sudo apt update && sudo apt install -y ufw
    fi
    
    # Configuración básica del firewall
    sudo ufw --force reset
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    
    # Permitir SSH (asegúrate de tener acceso SSH antes de activar)
    sudo ufw allow ssh
    
    # Permitir HTTP y HTTPS para el proxy
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    
    # Bloquear acceso directo a Ollama desde internet
    sudo ufw deny 11434/tcp
    
    # Bloquear acceso directo a WebUI desde internet  
    sudo ufw deny 3001/tcp
    
    # Activar firewall
    sudo ufw --force enable
    
    echo -e "${GREEN}✅ Firewall configurado${NC}"
    sudo ufw status verbose
}

# Función para configurar límites de rate limiting
setup_rate_limiting() {
    echo -e "\n${GREEN}Configurando protección DDoS básica...${NC}"
    
    # Crear configuración de fail2ban para nginx
    sudo mkdir -p /etc/fail2ban/jail.d/
    
    cat > /tmp/nginx-ai.conf << 'EOF'
[nginx-http-auth]
enabled = true
filter = nginx-http-auth
port = http,https
logpath = /var/log/nginx/error.log

[nginx-limit-req]
enabled = true
filter = nginx-limit-req
port = http,https
logpath = /var/log/nginx/error.log
maxretry = 10
findtime = 600
bantime = 7200
EOF

    if command -v fail2ban-server &> /dev/null; then
        sudo mv /tmp/nginx-ai.conf /etc/fail2ban/jail.d/
        sudo systemctl restart fail2ban
        echo -e "${GREEN}✅ Fail2ban configurado${NC}"
    else
        echo -e "${YELLOW}⚠️ Fail2ban no está instalado. Considera instalarlo para mayor seguridad.${NC}"
        echo "sudo apt install fail2ban"
    fi
}

# Función para generar claves SSL autopirma (para testing)
generate_self_signed_ssl() {
    echo -e "\n${GREEN}Generando certificados SSL auto-firmados para testing...${NC}"
    
    read -p "Ingresa tu dominio (o localhost): " DOMAIN
    DOMAIN=${DOMAIN:-localhost}
    
    mkdir -p nginx/ssl/live/$DOMAIN
    
    # Generar clave privada
    openssl genrsa -out nginx/ssl/live/$DOMAIN/privkey.pem 2048
    
    # Generar certificado
    openssl req -new -x509 -key nginx/ssl/live/$DOMAIN/privkey.pem \
        -out nginx/ssl/live/$DOMAIN/fullchain.pem -days 365 \
        -subj "/C=ES/ST=Madrid/L=Madrid/O=AI-Agent/OU=IT/CN=$DOMAIN"
    
    echo -e "${GREEN}✅ Certificados SSL generados en nginx/ssl/live/$DOMAIN/${NC}"
    echo -e "${YELLOW}⚠️ Estos son certificados de prueba. Para producción usa Let's Encrypt${NC}"
}

# Función para configurar Docker security
setup_docker_security() {
    echo -e "\n${GREEN}Configurando seguridad de Docker...${NC}"
    
    # Crear configuración de Docker daemon más segura
    cat > /tmp/docker-daemon.json << 'EOF'
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "10m",
        "max-file": "3"
    },
    "live-restore": true,
    "userland-proxy": false,
    "no-new-privileges": true
}
EOF
    
    if [[ -f /etc/docker/daemon.json ]]; then
        echo -e "${YELLOW}⚠️ Ya existe /etc/docker/daemon.json${NC}"
        echo "Configuración sugerida guardada en /tmp/docker-daemon.json"
    else
        sudo mv /tmp/docker-daemon.json /etc/docker/daemon.json
        echo -e "${GREEN}✅ Configuración de Docker aplicada${NC}"
        echo "Reinicia Docker: sudo systemctl restart docker"
    fi
}

# Función para verificar configuración de seguridad
check_security() {
    echo -e "\n${BLUE}🔍 Verificando configuración de seguridad...${NC}"
    
    # Verificar firewall
    if command -v ufw &> /dev/null; then
        echo -e "\n${GREEN}Estado del firewall:${NC}"
        sudo ufw status
    fi
    
    # Verificar puertos abiertos
    echo -e "\n${GREEN}Puertos en escucha:${NC}"
    sudo netstat -tlnp | grep -E ':(80|443|11434|3001|22)\s'
    
    # Verificar Docker
    echo -e "\n${GREEN}Contenedores corriendo:${NC}"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    
    # Verificar logs recientes
    echo -e "\n${GREEN}Logs recientes de autenticación:${NC}"
    sudo tail -10 /var/log/auth.log 2>/dev/null || echo "No se pueden leer logs de auth"
}

# Función para backup de configuración
backup_config() {
    echo -e "\n${GREEN}Creando backup de configuración...${NC}"
    
    BACKUP_DIR="backups/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    # Backup de archivos importantes
    cp -r nginx "$BACKUP_DIR/" 2>/dev/null || true
    cp docker-compose*.yml "$BACKUP_DIR/" 2>/dev/null || true
    cp .env "$BACKUP_DIR/" 2>/dev/null || echo "No .env file found"
    
    echo -e "${GREEN}✅ Backup creado en $BACKUP_DIR${NC}"
}

# Función para mostrar menú
show_menu() {
    echo -e "\n${YELLOW}Selecciona una acción:${NC}"
    echo "1. Configurar firewall básico"
    echo "2. Configurar protección DDoS"
    echo "3. Generar SSL auto-firmado (testing)"
    echo "4. Configurar seguridad de Docker"
    echo "5. Verificar configuración de seguridad"
    echo "6. Crear backup de configuración"
    echo "7. Configuración completa de seguridad"
    echo "8. Salir"
}

# Configuración completa
full_security_setup() {
    echo -e "\n${GREEN}Ejecutando configuración completa de seguridad...${NC}"
    
    setup_firewall
    setup_rate_limiting
    setup_docker_security
    backup_config
    
    echo -e "\n${GREEN}✅ Configuración de seguridad completada${NC}"
    echo -e "${YELLOW}Recomendaciones adicionales:${NC}"
    echo "1. Cambia las claves por defecto en .env"
    echo "2. Configura monitoreo de logs"
    echo "3. Actualiza regularmente los contenedores"
    echo "4. Considera usar Cloudflare para protección adicional"
}

# Función principal
main() {
    # Verificar permisos de sudo
    if [[ $EUID -eq 0 ]]; then
        echo -e "${RED}❌ No ejecutes este script como root${NC}"
        exit 1
    fi
    
    # Verificar sudo
    if ! sudo -n true 2>/dev/null; then
        echo -e "${YELLOW}Este script requiere permisos de sudo${NC}"
        sudo -v
    fi
    
    while true; do
        show_menu
        read -p "Selecciona una opción (1-8): " choice
        
        case $choice in
            1) setup_firewall ;;
            2) setup_rate_limiting ;;
            3) generate_self_signed_ssl ;;
            4) setup_docker_security ;;
            5) check_security ;;
            6) backup_config ;;
            7) full_security_setup ;;
            8) 
                echo -e "${BLUE}¡Configuración completada!${NC}"
                exit 0 
                ;;
            *) echo -e "${RED}❌ Opción inválida${NC}" ;;
        esac
    done
}

# Ejecutar función principal
main
