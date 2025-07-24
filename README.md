# IA Local para Desarrollo con Docker 🤖

Esta confi### Opción 3: Instalación Limpia (Completa) ✨

Si necesitas todos los modelos o quieres control manual:

```bash
./setup-ai-clean.sh
```

**Características:**
- 🧹 Limpieza manual con confirmaciones
- 📦 Opción de descargar modelos grandes
- 🔧 Control total del proceso
- ⏱️ Tiempo: 30-60 minutos

### Opción 4: Instalación Estándar

```bash
./setup-ai.sh
```

### Opción 5: Solo Limpieza

Si solo necesitas limpiar la configuración anterior:

```bash
./cleanup-ai.sh
```rmite ejecutar una IA local potente para desarrollo usando Docker y los mejores modelos de código abierto disponibles.

## 🚀 Características

- **Ollama** como servidor de IA local
- **Modelos de código abierto** más avanzados para programación
- **Interfaz web** para gestión de modelos
- **Configuración automática** con un solo comando
- **Compatible con GPU y CPU**
- **Integración perfecta con VS Code**

## 📋 Requisitos Previos

- Docker y Docker Compose instalados
- Al menos 8GB de RAM (16GB recomendado)
- 50GB de espacio libre en disco
- (Opcional) GPU NVIDIA con drivers instalados para mejor rendimiento
- **Para GPU NVIDIA**: NVIDIA Container Toolkit instalado

## 🛠️ Instalación Rápida

### Opción 1: Configuración Simple (Recomendada) ⚡

Para una configuración rápida sin conflictos de puertos:

```bash
./simple-setup.sh
```

**Características:**
- ✅ Puerto 3001 (evita conflictos con el 3000)
- ✅ Limpieza automática de puertos ocupados
- ✅ Solo modelos esenciales (15-20 minutos)
- ✅ Detección inteligente de GPU
- ✅ Configuración directa de Continue

### Opción 2: Configuración Automática (Más Rápida) ⚡

Para una configuración completamente automática sin interrupciones:

```bash
./quick-setup.sh
```

**Características:**
- ✅ Limpieza automática sin confirmaciones
- ✅ Descarga solo modelos esenciales (más rápido)
- ✅ Configuración completa en ~20-30 minutos
- ✅ No requiere interacción del usuario

### Opción 2: Instalación Limpia (Completa) ✨

Si necesitas todos los modelos o quieres control manual:

```bash
./setup-ai-clean.sh
```

**Características:**
- 🧹 Limpieza manual con confirmaciones
- � Opción de descargar modelos grandes
- 🔧 Control total del proceso
- ⏱️ Tiempo: 30-60 minutos

### Opción 3: Instalación Estándar

```bash
./setup-ai.sh
```

### Opción 4: Solo Limpieza

Si solo necesitas limpiar la configuración anterior:

```bash
./cleanup-ai.sh
```

## 🧠 Modelos Incluidos

### Modelos Especializados en Código

- **Qwen 2.5 Coder 32B**: El más avanzado para tareas complejas de código
- **Qwen 2.5 Coder 7B**: Rápido y eficiente para código simple
- **CodeLlama 34B**: Especialista en múltiples lenguajes de programación
- **DeepSeek Coder 33B**: Excelente para análisis y generación de código
- **Granite Code 34B**: Modelo de IBM optimizado para desarrollo

### Modelo de Uso General

- **Llama 3.1 8B**: Rápido para consultas generales y explicaciones

## 🔧 Configuración en VS Code

### Opción 1: Continue con Agentes (Recomendada) 🤖

1. Instala la extensión **Continue** desde el marketplace
2. Ejecuta el script de configuración automática:
```bash
./setup-continue-agents.sh
```
3. Reinicia VS Code
4. Abre Continue con `Ctrl+Shift+P` > "Continue: Open"
5. **¡Ahora verás la sección de Agentes!** Incluye:
   - **Asistente de Código**: Especialista en desarrollo y debugging
   - **Revisor de Código**: Analiza errores y vulnerabilidades
   - **Documentador**: Genera documentación técnica

### Verificar Configuración de Agentes
```bash
./check-continue-status.sh
```

### Opción 2: Configuración Manual

1. Copia el archivo `continue-config.json` a `~/.continue/config.json`
2. Reinicia VS Code
3. Usa `Ctrl+I` para chat inline o `Ctrl+Shift+P` > "Continue: Open"

### Opción 2: Otras extensiones compatibles

- **Codeium**: Configura con URL `http://localhost:11434`
- **Tabnine**: Usar modo local con la API de Ollama
- **GitHub Copilot Chat**: Configurar con endpoint local

## 🌐 URLs de Acceso

- **API de Ollama**: http://localhost:11434
- **Interfaz Web**: http://localhost:3001
- **Documentación API**: http://localhost:11434/api/tags

## 📝 Comandos Útiles

### Gestión de Contenedores
```bash
# Iniciar servicios
docker compose --profile cpu up -d  # Para CPU
docker compose --profile gpu up -d  # Para GPU

# Parar servicios
docker compose down

# Ver logs
docker compose logs -f

# Reiniciar servicios
docker compose restart
```

### Gestión de Modelos
```bash
# Listar modelos instalados
docker exec ollama-dev-ai-cpu ollama list

# Descargar un nuevo modelo
docker exec ollama-dev-ai-cpu ollama pull modelo:tag

# Eliminar un modelo
docker exec ollama-dev-ai-cpu ollama rm modelo:tag

# Chat interactivo con un modelo
docker exec -it ollama-dev-ai-cpu ollama run qwen2.5-coder:7b
```

## 💡 Comandos Personalizados para Continue

La configuración incluye comandos personalizados:

- `/explain`: Explica código en español
- `/optimize`: Optimiza código para rendimiento
- `/fix`: Encuentra y corrige errores
- `/test`: Genera tests unitarios
- `/document`: Genera documentación completa
- `/refactor`: Refactoriza siguiendo mejores prácticas

## ⚡ Recomendaciones de Uso

### Para Mejor Rendimiento:
- **Código simple**: Usa `qwen2.5-coder:7b`
- **Código complejo**: Usa `qwen2.5-coder:32b`
- **Explicaciones**: Usa `llama3.1:8b`
- **Debugging**: Usa `deepseek-coder:33b`

### Para Ahorrar Recursos:
- Usa solo los modelos que necesites
- Cierra VS Code cuando no lo uses para liberar memoria
- Considera usar modelos más pequeños en sistemas con poca RAM

## 🔧 Personalización

### Cambiar Configuración de Continue
Edita `~/.continue/config.json` para:
- Ajustar temperatura (creatividad)
- Cambiar modelo por defecto
- Agregar comandos personalizados
- Modificar prompts

### Agregar Nuevos Modelos
```bash
# Buscar modelos disponibles
docker exec ollama-dev-ai-cpu ollama search coder

# Descargar modelo específico
docker exec ollama-dev-ai-cpu ollama pull nuevo-modelo:tag
```

## 🐛 Solución de Problemas

### Puerto 11434 u otros puertos ocupados

Si recibes errores de puertos ocupados (11434, 3001):

```bash
# Opción 1: Usar el script de limpieza automática
./cleanup-ai.sh

# Opción 2: Liberar puertos manualmente
sudo netstat -tlnp | grep -E "(11434|3001)"
sudo pkill -f "docker-proxy.*(11434|3001)"

# Opción 3: Reiniciar Docker
sudo systemctl restart docker
```

### Configuración de GPU NVIDIA en Fedora

Si tienes problemas con GPU en Fedora:

```bash
# Instalar NVIDIA Container Toolkit
curl -s -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo | sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo

# Remover conflictos (si existen)
sudo dnf remove golang-github-nvidia-container-toolkit -y

# Instalar el toolkit
sudo dnf install -y nvidia-container-toolkit

# Configurar Docker
sudo nvidia-ctk runtime configure --runtime=docker

# Reiniciar Docker
sudo systemctl restart docker

# Probar GPU
docker run --rm --runtime=nvidia --gpus all nvidia/cuda:11.0.3-base-ubuntu20.04 nvidia-smi
```

### Error de Memoria
Si recibes errores de memoria:
1. Reduce el número de modelos cargados
2. Usa modelos más pequeños (7B en lugar de 32B)
3. Aumenta la memoria virtual (swap)

### Modelos No Responden
1. Verifica que el contenedor esté corriendo: `docker ps`
2. Revisa los logs: `docker-compose logs ollama`
3. Reinicia el servicio: `docker-compose restart`

### VS Code No Conecta
1. Verifica que Ollama esté en http://localhost:11434
2. Comprueba la configuración de Continue
3. Reinicia la extensión

## 📈 Próximos Pasos

1. **Explora la interfaz web** en http://localhost:3001
2. **Personaliza los prompts** según tus necesidades
3. **Prueba diferentes modelos** para distintas tareas
4. **Configura atajos de teclado** personalizados en VS Code

## 🤝 Contribuir

¿Tienes sugerencias o mejoras? ¡Abre un issue o envía un PR!

---

**¡Disfruta de tu IA local para desarrollo! 🎉**
