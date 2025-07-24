#!/bin/bash

# Script para optimizar recursos para Continue en VS Code
echo "🔧 Optimizando recursos para Continue..."

# Mostrar uso actual de memoria
echo "📊 Uso actual de memoria:"
free -h

echo ""
echo "🧠 Modelos disponibles y su uso de memoria:"
echo "  • llama3.2:1b         -> ~1.3 GB RAM (✅ Funciona)"
echo "  • deepseek-coder:6.7b -> ~4.0 GB RAM (⚠️  Requiere más memoria)"
echo "  • qwen2.5-coder:7b    -> ~5.4 GB RAM (❌ No suficiente memoria)"

# Verificar si hay procesos que consumen mucha memoria
echo ""
echo "🔍 Procesos que más memoria consumen:"
ps aux --sort=-%mem | head -10

# Sugerir optimizaciones
echo ""
echo "💡 Sugerencias para liberar memoria:"
echo "  1. Cierra aplicaciones innecesarias (navegador, etc.)"
echo "  2. Reinicia VS Code para liberar memoria"
echo "  3. Usa solo el modelo llama3.2:1b por ahora"
echo "  4. Considera aumentar swap si es necesario"

# Función para limpiar cache del sistema
read -p "¿Quieres limpiar cache del sistema? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🧹 Limpiando cache..."
    sudo sync && echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
    echo "✅ Cache limpiado"
fi

echo ""
echo "🎯 Para usar en VS Code:"
echo "  1. Reinicia VS Code"
echo "  2. Presiona Ctrl+Shift+P"
echo "  3. Busca 'Continue: Open'"
echo "  4. Usa el modelo 'Llama 3.2 1B' que está optimizado"
echo ""
echo "🎉 ¡Listo para programar con IA local!"
