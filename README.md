# IA Local para Desarrollo con Docker 🤖

Esta configuración permite ejecutar una IA local potente para desarrollo usando Docker y los mejores modelos de código abierto disponibles.

## 🚀 Características

- **Ollama** como servidor de IA local (v0.9.6)
- **Modelos de código abierto** más avanzados para programación
- **Interfaz web** OpenWebUI para gestión intuitiva de modelos
- **Configuración automática** con detección de GPU
- **Compatible con GPU NVIDIA y CPU**
- **Integración perfecta con VS Code** vía Continue
- **Scripts automatizados** para instalación y mantenimiento

## ✅ Estado del Proyecto (Verificado)

Este proyecto ha sido **probado y verificado** el 31 de julio de 2025 con:

- ✅ **Docker 28.3.2** + **Docker Compose v2.38.2**
- ✅ **Fedora 42 Workstation** (Kernel 6.15.7)
- ✅ **NVIDIA GeForce RTX 4060 Laptop GPU** (8GB VRAM)
- ✅ **Ollama v0.9.6** ejecutándose correctamente
- ✅ **OpenWebUI** funcionando en puerto 3001
- ✅ **Modelos activos**: Qwen 2.5 Coder 7B + Llama 3.1 8B
- ✅ **API de Ollama** respondiendo en puerto 11434
- ✅ **Continue configurado** para VS Code

### Rendimiento Verificado

- **Tiempo de inicio**: ~3 segundos para cargar modelo en GPU
- **Memoria GPU utilizada**: ~450MB para cache KV del modelo 7B
- **Respuesta típica**: 4-7 segundos para consultas de código


## 📋 Requisitos Previos

### Requisitos Mínimos del Sistema

- **Docker**: versión 20.10+ (probado con 28.3.2)
- **Docker Compose**: v2.0+ (probado con v2.38.2)
- **RAM**: Mínimo 8GB (16GB recomendado para múltiples modelos)
- **Espacio en disco**: 50GB libres (para modelos y cache)
- **Sistema operativo**: Linux (probado en Fedora 42), macOS, Windows con WSL2

### Para GPU NVIDIA (Opcional pero Recomendado)

- **GPU**: NVIDIA con al menos 6GB VRAM (probado con RTX 4060 Laptop - 8GB)
- **Drivers**: NVIDIA drivers actualizados
- **NVIDIA Container Toolkit**: Para acelerar la inferencia

### Instalación del NVIDIA Container Toolkit (Fedora)

```bash
# Agregar repositorio
curl -s -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo | sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo

# Instalar toolkit
sudo dnf install -y nvidia-container-toolkit

# Configurar Docker
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

# Verificar instalación
docker run --rm --runtime=nvidia --gpus all nvidia/cuda:11.0.3-base-ubuntu20.04 nvidia-smi
```

## 🛠️ Instalación Rápida

### Opción 1: Configuración Automática (Recomendada) ⚡

Para una configuración automática con detección inteligente de GPU:

```bash
./auto-setup.sh
```

**Características:**
- ✅ Detección automática de GPU NVIDIA
- ✅ Limpieza automática de puertos ocupados
- ✅ Descarga de modelos esenciales
- ✅ Configuración de Continue para VS Code
- ⏱️ Tiempo: 15-30 minutos

### Opción 2: Instalación Manual

Para usuarios que prefieren control total del proceso:

```bash
# 1. Levantar con GPU (si tienes NVIDIA)
docker compose --profile gpu up -d

# 2. O levantar con CPU solamente
docker compose --profile cpu up -d

# 3. Instalar modelos esenciales
docker exec ollama-dev-ai ollama pull qwen2.5-coder:7b
docker exec ollama-dev-ai ollama pull llama3.1:8b
```

### Opción 3: Solo Limpieza

Si necesitas limpiar la configuración anterior:

```bash
./cleanup-ai.sh
```

## 🧠 Modelos Incluidos

### Modelos Verificados y Funcionando

Estos modelos han sido probados y están funcionando correctamente en el sistema:

- **Qwen 2.5 Coder 7B**: Especializado en código, rápido y eficiente (4.68 GB)
- **Llama 3.1 8B**: Modelo de uso general para explicaciones y consultas (4.92 GB)

### Modelos Adicionales Disponibles

Puedes instalar estos modelos según tus necesidades:

- **Qwen 2.5 Coder 32B**: El más avanzado para tareas complejas de código (~20 GB)
- **CodeLlama 7B**: Especialista en múltiples lenguajes de programación
- **DeepSeek Coder 6.7B**: Excelente para análisis y generación de código
- **Llama 3.2 1B**: Modelo ligero para respuestas rápidas

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

### Verificación Rápida del Sistema

Usa el script de verificación incluido:

```bash
./check-continue-status.sh
```

Este script verifica automáticamente:
- Estado de contenedores Docker
- Conectividad con Ollama API
- Configuración de Continue
- Modelos disponibles

### Puerto 11434 u otros puertos ocupados

Si recibes errores de puertos ocupados:

```bash
# Opción 1: Usar script de limpieza (recomendado)
./cleanup-ai.sh

# Opción 2: Verificar manualmente qué usa los puertos
sudo netstat -tlnp | grep -E "(11434|3001)"

# Opción 3: Forzar liberación de puertos
sudo pkill -f "docker-proxy.*(11434|3001)"
```

### Problemas con GPU NVIDIA

Si el sistema no detecta tu GPU:

```bash
# Verificar que la GPU es visible
nvidia-smi

# Verificar Docker + NVIDIA
docker run --rm --runtime=nvidia --gpus all nvidia/cuda:11.0.3-base-ubuntu20.04 nvidia-smi

# Si falla, reinstalar NVIDIA Container Toolkit
sudo dnf install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

### Error "No such profile: gpu"

Si recibes este error, usa el perfil CPU:

```bash
docker compose --profile cpu up -d
```

### Modelos No Cargan o Son Lentos

1. **Verificar memoria disponible**:
   ```bash
   free -h
   # GPU memory
   nvidia-smi
   ```

2. **Usar modelos más pequeños**:
   ```bash
   # En lugar de modelos 32B, usa 7B
   docker exec ollama-dev-ai ollama pull qwen2.5-coder:7b
   ```

3. **Verificar logs de Ollama**:
   ```bash
   docker compose logs --tail=20 ollama
   ```

## 📈 Próximos Pasos

### Después de la Instalación

1. **Accede a la interfaz web**: <http://localhost:3001>
2. **Instala Continue en VS Code** desde el marketplace
3. **Copia la configuración**: `cp continue-config.json ~/.continue/config.json`
4. **Reinicia VS Code** y prueba `Ctrl+I` para chat inline

### Personalización Avanzada

1. **Instala modelos adicionales** según tus necesidades:
   ```bash
   # Para proyectos más complejos
   docker exec ollama-dev-ai ollama pull qwen2.5-coder:32b
   
   # Para desarrollo web
   docker exec ollama-dev-ai ollama pull codellama:7b
   ```

2. **Configura comandos personalizados** editando `continue-config.json`
3. **Ajusta la temperatura** del modelo para creatividad vs precisión
4. **Configura atajos de teclado** en VS Code para acceso rápido

### Monitoreo y Optimización

- **Monitorea el uso de memoria**: `docker stats`
- **Revisa logs periódicamente**: `docker compose logs --tail=50`
- **Actualiza modelos**: Los nuevos modelos se lanzan frecuentemente

## 🤝 Contribuir

¿Tienes sugerencias o mejoras? ¡Abre un issue o envía un PR!

---

### ¡Disfruta de tu IA local para desarrollo! 🎉

> Proyecto verificado y funcionando el 31 de julio de 2025
> Sistema probado: Fedora 42 + Docker 28.3.2 + RTX 4060 Laptop GPU
