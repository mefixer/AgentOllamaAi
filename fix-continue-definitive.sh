#!/bin/bash

# Script para solucionar definitivamente el problema de "No models configured" 
# Autor: Script generado para AgentOllamaAi

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔧 Solución definitiva para 'No models configured'...${NC}"

CONTINUE_DIR="$HOME/.continue"

# 1. Verificar Ollama
echo -e "${YELLOW}1. Verificando Ollama...${NC}"
if curl -s http://localhost:11434/api/version > /dev/null; then
    echo -e "${GREEN}✅ Ollama funcionando${NC}"
else
    echo -e "${RED}❌ Ollama no responde${NC}"
    exit 1
fi

# 2. Crear respaldo completo
echo -e "${YELLOW}2. Creando respaldo completo...${NC}"
BACKUP_DIR="$CONTINUE_DIR/backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -r "$CONTINUE_DIR"/* "$BACKUP_DIR/" 2>/dev/null || true
echo -e "${GREEN}✅ Respaldo creado en $BACKUP_DIR${NC}"

# 3. Limpiar cache completo
echo -e "${YELLOW}3. Limpiando cache completo...${NC}"
rm -rf "$CONTINUE_DIR/index" "$CONTINUE_DIR/dev_data" "$CONTINUE_DIR/sessions" 2>/dev/null || true
rm -rf "$CONTINUE_DIR/.utils" 2>/dev/null || true
echo -e "${GREEN}✅ Cache limpiado${NC}"

# 4. Configurar JSON
echo -e "${YELLOW}4. Configurando config.json...${NC}"
cat > "$CONTINUE_DIR/config.json" << 'EOF'
{
  "models": [
    {
      "title": "Qwen 2.5 Coder 7B - Programación",
      "provider": "ollama",
      "model": "qwen2.5-coder:7b",
      "apiBase": "http://localhost:11434"
    },
    {
      "title": "DeepSeek Coder 6.7B - Código",
      "provider": "ollama",
      "model": "deepseek-coder:6.7b",
      "apiBase": "http://localhost:11434"
    },
    {
      "title": "CodeLlama 7B - Desarrollo",
      "provider": "ollama",
      "model": "codellama:7b",
      "apiBase": "http://localhost:11434"
    },
    {
      "title": "Llama 3.1 8B - General",
      "provider": "ollama",
      "model": "llama3.1:8b",
      "apiBase": "http://localhost:11434"
    },
    {
      "title": "Llama 3.2 1B - Rápido",
      "provider": "ollama",
      "model": "llama3.2:1b",
      "apiBase": "http://localhost:11434"
    }
  ],
  "customCommands": [
    {
      "name": "explain",
      "prompt": "Explica este código en español: {{{ input }}}"
    }
  ],
  "allowAnonymousTelemetry": false
}
EOF
echo -e "${GREEN}✅ config.json configurado${NC}"

# 5. Configurar YAML
echo -e "${YELLOW}5. Configurando config.yaml...${NC}"
cat > "$CONTINUE_DIR/config.yaml" << 'EOF'
name: Local Assistant
version: 1.0.0
schema: v1
models:
  - title: "Qwen 2.5 Coder 7B - Programación"
    provider: ollama
    model: qwen2.5-coder:7b
    apiBase: http://localhost:11434
  - title: "DeepSeek Coder 6.7B - Código"
    provider: ollama
    model: deepseek-coder:6.7b
    apiBase: http://localhost:11434
  - title: "CodeLlama 7B - Desarrollo"
    provider: ollama
    model: codellama:7b
    apiBase: http://localhost:11434
  - title: "Llama 3.1 8B - General"
    provider: ollama
    model: llama3.1:8b
    apiBase: http://localhost:11434
  - title: "Llama 3.2 1B - Rápido"
    provider: ollama
    model: llama3.2:1b
    apiBase: http://localhost:11434
context:
  - provider: code
  - provider: docs
  - provider: diff
  - provider: terminal
  - provider: problems
  - provider: folder
  - provider: codebase
EOF
echo -e "${GREEN}✅ config.yaml configurado${NC}"

# 6. Eliminar archivos problemáticos (si existen)
echo -e "${YELLOW}6. Limpiando archivos problemáticos...${NC}"
rm -f "$CONTINUE_DIR/.continueignore" 2>/dev/null || true
rm -f "$CONTINUE_DIR/.continuerc.json" 2>/dev/null || true
echo -e "${GREEN}✅ Archivos problemáticos eliminados${NC}"

# 7. Verificar configuraciones
echo -e "${YELLOW}7. Verificando configuraciones...${NC}"
if jq -e '.models | length > 0' "$CONTINUE_DIR/config.json" > /dev/null 2>&1; then
    MODELS_JSON=$(jq -r '.models | length' "$CONTINUE_DIR/config.json")
    echo -e "${GREEN}✅ JSON válido con $MODELS_JSON modelos${NC}"
else
    echo -e "${RED}❌ Error en config.json${NC}"
fi

if grep -q "qwen2.5-coder:7b" "$CONTINUE_DIR/config.yaml"; then
    echo -e "${GREEN}✅ YAML configurado correctamente${NC}"
else
    echo -e "${RED}❌ Error en config.yaml${NC}"
fi

# 8. Reiniciar permisos
echo -e "${YELLOW}8. Ajustando permisos...${NC}"
chmod 644 "$CONTINUE_DIR/config.json" "$CONTINUE_DIR/config.yaml"
echo -e "${GREEN}✅ Permisos ajustados${NC}"

echo -e "${BLUE}🎉 Configuración completa!${NC}"
echo -e "${YELLOW}📝 Pasos finales OBLIGATORIOS:${NC}"
echo -e "1. ${RED}CIERRA VS Code COMPLETAMENTE${NC}"
echo -e "2. ${RED}Abre VS Code de nuevo${NC}"
echo -e "3. ${GREEN}Abre Continue desde la barra lateral${NC}"
echo -e "4. ${GREEN}Los modelos deberían aparecer ahora${NC}"
echo ""
echo -e "${BLUE}💡 Si AÚN no funciona:${NC}"
echo -e "• Desinstala completamente la extensión Continue"
echo -e "• Reinicia VS Code"
echo -e "• Reinstala la extensión Continue"
echo -e "• Ejecuta este script nuevamente"
