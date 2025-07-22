#!/bin/bash

# Script de inicio rápido para la IA local

echo "🚀 Inicio Rápido - IA Local para Desarrollo"
echo ""

# Verificar Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker no está instalado. Instálalo primero:"
    echo "   sudo apt-get update && sudo apt-get install docker.io"
    exit 1
fi

# Verificar si Docker está corriendo
if ! docker info &> /dev/null; then
    echo "❌ Docker no está corriendo. Inicia el servicio:"
    echo "   sudo systemctl start docker"
    exit 1
fi

echo "✅ Docker verificado"

# Verificar si ya hay servicios corriendo
if docker ps | grep -q "ollama"; then
    echo "⚠️  Ya hay servicios de Ollama corriendo"
    echo ""
    ./manage-models.sh status
    exit 0
fi

echo ""
echo "🤖 Opciones de instalación:"
echo "1. Rápida (solo modelos ligeros - ~20GB)"
echo "2. Recomendada (modelos balanceados - ~35GB)" 
echo "3. Completa (todos los modelos - ~150GB)"
echo "4. Solo iniciar servicios (sin descargar modelos)"
echo ""
read -p "Selecciona una opción (1-4): " option

case $option in
    1)
        echo "📦 Instalación rápida seleccionada"
        INSTALL_TYPE="lightweight"
        ;;
    2)
        echo "📦 Instalación recomendada seleccionada"
        INSTALL_TYPE="recommended"
        ;;
    3)
        echo "📦 Instalación completa seleccionada"
        INSTALL_TYPE="full"
        ;;
    4)
        echo "📦 Solo iniciando servicios"
        INSTALL_TYPE="none"
        ;;
    *)
        echo "❌ Opción inválida"
        exit 1
        ;;
esac

# Detectar GPU
if command -v nvidia-smi &> /dev/null; then
    echo "✅ GPU NVIDIA detectada"
    PROFILE="gpu"
else
    echo "ℹ️  Usando CPU (sin GPU detectada)"
    PROFILE="cpu"
fi

# Iniciar servicios
echo "🐳 Iniciando servicios..."
docker compose --profile $PROFILE up -d

# Esperar a que Ollama esté listo
echo "⏳ Esperando a que Ollama esté listo..."
sleep 15

# Instalar modelos según la opción seleccionada
if [ "$INSTALL_TYPE" != "none" ]; then
    echo "📥 Instalando modelos ($INSTALL_TYPE)..."
    ./manage-models.sh $INSTALL_TYPE
fi

echo ""
echo "✅ ¡Instalación completada!"
echo ""
echo "🔗 Accesos disponibles:"
echo "   • API de Ollama: http://localhost:11434"
echo "   • Interfaz Web: http://localhost:3000"
echo ""
echo "📝 Próximos pasos:"
echo "1. Instala la extensión 'Continue' en VS Code"
echo "2. Copia el archivo continue-config.json a ~/.continue/config.json"
echo "3. Reinicia VS Code"
echo "4. Usa Ctrl+I para autocompletado inline"
echo ""
echo "💡 Comandos útiles:"
echo "   ./manage-models.sh status    # Ver estado"
echo "   ./manage-models.sh list      # Listar modelos"
echo "   ./manage-models.sh chat <modelo>  # Chat con modelo"
echo ""
echo "¡Disfruta tu IA local! 🎉"
