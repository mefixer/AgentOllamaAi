# 🌐 Exposición del Agente IA a Internet

Esta guía te ayudará a exponer tu agente de IA local a internet de forma segura.

## 📋 Requisitos Previos

- Docker y Docker Compose instalados
- Un dominio (para opciones con SSL)
- Servidor con IP pública (VPS, servidor dedicado, etc.)
- Puertos 80 y 443 disponibles (para opciones con Nginx)

## 🚀 Opciones de Despliegue

### Opción 1: Nginx + SSL (Recomendado para VPS)

**Características:**
- ✅ SSL automático con Let's Encrypt
- ✅ Proxy reverso con Nginx
- ✅ Rate limiting y protección básica
- ✅ Headers de seguridad configurados

**Pasos:**
```bash
# 1. Ejecutar configuración automática
./setup-web-exposure.sh

# 2. Seleccionar opción 1
# 3. Ingresar tu dominio y email
# 4. Iniciar servicios
docker-compose -f docker-compose-web.yml --profile cpu up -d

# 5. Obtener certificado SSL
docker-compose -f docker-compose-web.yml --profile ssl run --rm certbot

# 6. Reiniciar Nginx
docker-compose -f docker-compose-web.yml restart nginx
```

### Opción 2: Cloudflare Tunnel (Más Seguro)

**Características:**
- ✅ Sin necesidad de abrir puertos
- ✅ Protección DDoS de Cloudflare
- ✅ SSL automático
- ✅ No requiere IP pública estática

**Pasos:**
```bash
# 1. Crear cuenta en Cloudflare
# 2. Agregar tu dominio a Cloudflare
# 3. Ir a Zero Trust → Networks → Tunnels
# 4. Crear nuevo tunnel y copiar token
# 5. Ejecutar configuración
./setup-web-exposure.sh

# 6. Seleccionar opción 2 e ingresar token
# 7. Iniciar servicios
docker-compose -f docker-compose-cloudflare.yml up -d
```

### Opción 3: Setup Seguro con Autenticación

**Características:**
- ✅ Autenticación de doble factor
- ✅ Control de acceso granular
- ✅ Protección adicional con Authelia

```bash
# 1. Ejecutar configuración
./setup-web-exposure.sh

# 2. Seleccionar opción 3
# 3. Configurar autenticación
docker-compose -f docker-compose-secure.yml up -d
```

## 🔒 Configuración de Seguridad

Ejecuta el script de seguridad para protección adicional:

```bash
./setup-security.sh
```

**Opciones disponibles:**
- Configuración de firewall (ufw)
- Protección DDoS con fail2ban
- Certificados SSL auto-firmados (testing)
- Seguridad de Docker
- Verificación de configuración

## 📁 Estructura de Archivos

```
Agent/
├── docker-compose-web.yml          # Nginx + SSL
├── docker-compose-cloudflare.yml   # Cloudflare Tunnel
├── docker-compose-secure.yml       # Setup seguro
├── nginx/
│   ├── nginx.conf                  # Configuración Nginx
│   └── ssl/                        # Certificados SSL
├── setup-web-exposure.sh           # Script de configuración
├── setup-security.sh               # Script de seguridad
└── .env                            # Variables de entorno
```

## 🌍 Acceso a tu Agente

Una vez configurado, podrás acceder a:

- **WebUI**: `https://tu-dominio.com`
- **API Ollama**: Solo acceso interno (más seguro)

## 🔧 Variables de Entorno

Crea un archivo `.env` con:

```env
# Claves secretas (generadas automáticamente)
WEBUI_SECRET_KEY=tu-clave-secreta
WEBUI_JWT_SECRET_KEY=tu-jwt-secreto

# Cloudflare (solo para opción 2)
CLOUDFLARE_TUNNEL_TOKEN=tu-token-cloudflare

# Configuración
DOMAIN=tu-dominio.com
EMAIL=tu-email@domain.com
ENABLE_SIGNUP=false
```

## 🛡️ Medidas de Seguridad Implementadas

### Nginx + SSL:
- Rate limiting (10 req/s general, 1 req/s login)
- Headers de seguridad (HSTS, CSP, etc.)
- Bloqueo de acceso directo a Ollama
- SSL con ciphers modernos

### Cloudflare Tunnel:
- Sin puertos expuestos públicamente
- Protección DDoS de Cloudflare
- SSL/TLS edge termination

### Firewall:
- Solo puertos 22, 80, 443 abiertos
- Bloqueo de acceso directo a 11434, 3001
- Protección básica DDoS

## 🚨 Consideraciones de Seguridad

1. **Cambiar claves por defecto**: Siempre cambia las claves generadas
2. **Desactivar registro público**: `ENABLE_SIGNUP=false`
3. **Monitoreo**: Revisa logs regularmente
4. **Actualizaciones**: Mantén contenedores actualizados
5. **Backup**: Respalda configuración regularmente

## 📊 Monitoreo

### Ver logs en tiempo real:
```bash
# Logs de WebUI
docker logs -f open-webui-public

# Logs de Nginx
docker logs -f ai-nginx-proxy

# Logs de Ollama
docker logs -f ollama-web-ai-cpu
```

### Verificar estado:
```bash
# Estado de contenedores
docker ps

# Verificar configuración de seguridad
./setup-security.sh
# Seleccionar opción 5
```

## 🔄 Comandos Útiles

```bash
# Iniciar servicios
docker-compose -f docker-compose-web.yml --profile cpu up -d

# Detener servicios
docker-compose -f docker-compose-web.yml down

# Reiniciar un servicio específico
docker-compose -f docker-compose-web.yml restart nginx

# Ver estadísticas de uso
docker stats

# Actualizar imágenes
docker-compose -f docker-compose-web.yml pull
docker-compose -f docker-compose-web.yml up -d
```

## 🆘 Troubleshooting

### Error de SSL:
```bash
# Verificar certificados
docker-compose -f docker-compose-web.yml --profile ssl run --rm certbot certificates

# Renovar certificados
docker-compose -f docker-compose-web.yml --profile ssl run --rm certbot renew
```

### Error de conexión:
```bash
# Verificar firewall
sudo ufw status

# Verificar puertos
sudo netstat -tlnp | grep -E ':(80|443|11434)'

# Verificar DNS
nslookup tu-dominio.com
```

### Performance issues:
```bash
# Verificar recursos
docker stats

# Limpiar logs
docker system prune

# Verificar límites de rate
grep -i "limit" /var/log/nginx/error.log
```

## 📞 Soporte

Si tienes problemas:

1. Revisa los logs de los contenedores
2. Verifica la configuración de DNS
3. Confirma que el firewall esté configurado correctamente
4. Asegúrate de que el dominio apunte a tu servidor

## 🎯 Próximos Pasos

Una vez funcionando:

1. Configura backups automáticos
2. Implementa monitoreo con Prometheus/Grafana
3. Considera usar un CDN
4. Configura alertas de seguridad
