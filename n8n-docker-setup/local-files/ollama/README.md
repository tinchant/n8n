# Ollama + n8n AI Starter Kit

Este diretório contém arquivos e configurações relacionados ao Ollama integrado com o n8n AI Starter Kit, uma versão especializada do n8n com recursos avançados de IA.

## Integração com n8n AI Starter Kit

O n8n AI Starter Kit está configurado para usar automaticamente o modelo **deepseek-r1:8b** como modelo padrão para:

1. **Processamento de linguagem natural**: Análise, resumo, tradução
2. **Geração de conteúdo inteligente**: Textos, e-mails, documentos
3. **Análise e classificação**: Categorização automática de dados
4. **Chatbots avançados**: Respostas contextuais inteligentes
5. **Extração de informações**: Parsing de documentos não estruturados

## Modelo Padrão: deepseek-r1:8b

O modelo **deepseek-r1:8b** foi selecionado por ser:
- **Eficiente**: Boa performance com 8B parâmetros
- **Versátil**: Excelente para tarefas gerais de NLP
- **Rápido**: Tempos de resposta otimizados
- **Multilíngue**: Suporte a português e outros idiomas

## Comandos Básicos

### Iniciar o ambiente AI completo
```bash
# Via PowerShell (recomendado):
docker-compose --profile development --profile ai up -d

# Inicializar modelo deepseek-r1:8b automaticamente:
docker-compose run --rm ollama-init

# Ou usar comando make (se disponível):
make dev-ai-full
```

### Comandos específicos do modelo deepseek-r1:8b
```bash
# Baixar apenas o deepseek-r1:8b:
docker-compose exec ollama ollama pull deepseek-r1:8b

# Testar o modelo:
docker-compose exec ollama ollama run deepseek-r1:8b

# Via make:
make ollama-deepseek
```

### Listar modelos instalados
```bash
docker-compose exec ollama ollama list
# Ou: make ollama-models
```

### Testar um modelo
```bash
docker-compose exec ollama ollama run llama2
# Ou: make ollama-run MODEL=llama2
```

## Uso no n8n AI Starter Kit

### Integração Nativa

O n8n AI Starter Kit tem **integração nativa** com Ollama. Não é necessário configurar manualmente:

1. **Nodes AI nativos**: Use os nodes específicos de AI/LLM
2. **Modelo padrão**: `deepseek-r1:8b` já configurado
3. **URL automática**: `http://ollama:11434` pré-configurada

### Nodes Recomendados:

- **AI Agent**: Para conversação e raciocínio
- **AI Transform**: Para transformação de dados
- **AI Summarizer**: Para resumos automáticos
- **AI Classifier**: Para classificação de conteúdo

### Exemplo Manual (HTTP Request):

Se precisar fazer chamadas diretas:

1. **HTTP Request Node**:
   - URL: `http://ollama:11434/api/generate`
   - Method: POST
   - Body:
   ```json
   {
     "model": "deepseek-r1:8b",
     "prompt": "Analise este texto: {{$node['Input'].json['text']}}",
     "stream": false
   }
   ```

## Modelos Disponíveis

### Modelo Principal (Pré-configurado):
- **deepseek-r1:8b**: Modelo padrão otimizado para o n8n AI Starter Kit
  - 8B parâmetros
  - Excelente para português
  - Rápido e eficiente
  - Integração nativa com n8n

### Modelos Adicionais Recomendados:

#### Para Português:
- **llama2:7b**: Modelo confiável para conversação
- **mistral:7b**: Mais rápido, boa qualidade

#### Para Código:
- **codellama:7b**: Especializado em programação
- **deepseek-coder**: Foco em desenvolvimento

#### Modelos Menores (hardware limitado):
- **tinyllama**: Muito leve (~1GB)
- **phi3:mini**: Modelo da Microsoft, eficiente

## Configurações de Performance

As configurações podem ser ajustadas no `.env`:

```env
# Número de modelos carregados simultaneamente
OLLAMA_MAX_LOADED_MODELS=3

# Processamento paralelo
OLLAMA_NUM_PARALLEL=2
```

## Troubleshooting

### Ollama não responde:
1. Verificar se o container está rodando: `docker-compose ps`
2. Verificar logs: `docker-compose logs ollama`
3. Testar API: `curl http://localhost:11434/api/tags`

### Modelo demora para carregar:
- Modelos grandes (7B+) podem demorar alguns minutos na primeira execução
- Verifique se há RAM/VRAM suficiente

### Erro de memória:
- Reduza `OLLAMA_MAX_LOADED_MODELS` no `.env`
- Use modelos menores (tinyllama, phi)

## GPU (NVIDIA)

Se você tem uma GPU NVIDIA:

1. Instale o NVIDIA Container Toolkit
2. O docker-compose já está configurado para usar GPU
3. Modelos rodarão muito mais rápido

## Arquivos

- `models/`: Modelos personalizados (se houver)
- `README.md`: Este arquivo
- Logs ficam no volume Docker `ollama_data`
