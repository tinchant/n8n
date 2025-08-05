# 📱 EVOLUTION API - INTEGRAÇÃO WHATSAPP

## 🚀 **OVERVIEW**

Este setup inclui a **Evolution API** para integração completa com WhatsApp, permitindo:
- Envio e recebimento de mensagens via API
- Gerenciamento de múltiplas instâncias WhatsApp
- Webhooks para automações com n8n
- Interface web para gerenciamento

## 🔧 **CONFIGURAÇÕES**

### **Acesso aos Serviços:**
- **Evolution API**: `https://evolution.roladb.com.br`
- **Documentação**: `https://evolution.roladb.com.br/manager/docs`
- **Manager**: `https://evolution.roladb.com.br/manager`

### **Credenciais:**
- **API Key**: `evolution_api_key_123456` (configurado no .env)
- **Authentication Type**: `apikey`

## 📋 **COMO USAR**

### **1. Criar uma Instância WhatsApp:**
```bash
curl -X POST https://evolution.roladb.com.br/instance/create \
  -H "Content-Type: application/json" \
  -H "apikey: evolution_api_key_123456" \
  -d '{
    "instanceName": "minha_instancia",
    "token": "meu_token_secreto",
    "qrcode": true,
    "webhook": "https://n8n.roladb.com.br/webhook/whatsapp"
  }'
```

### **2. Conectar WhatsApp:**
```bash
# Gerar QR Code
curl -X GET https://evolution.roladb.com.br/instance/connect/minha_instancia \
  -H "apikey: evolution_api_key_123456"
```

### **3. Enviar Mensagem:**
```bash
curl -X POST https://evolution.roladb.com.br/message/sendText/minha_instancia \
  -H "Content-Type: application/json" \
  -H "apikey: evolution_api_key_123456" \
  -d '{
    "number": "5511999999999",
    "textMessage": {
      "text": "Olá! Esta é uma mensagem via Evolution API"
    }
  }'
```

## 🔗 **INTEGRAÇÃO COM N8N**

### **Webhook URL para receber mensagens:**
```
https://n8n.roladb.com.br/webhook/whatsapp
```

### **Exemplo de Workflow N8N:**
1. **Webhook Trigger** → Recebe mensagens do WhatsApp
2. **Function Node** → Processa a mensagem recebida
3. **HTTP Request** → Envia resposta via Evolution API

## 🏗️ **ARQUITETURA**

```
WhatsApp ↔ Evolution API ↔ n8n ↔ Outros Serviços
            ↓
         PostgreSQL (Persistência)
            ↓
         Redis (Cache/Queue)
            ↓
         RabbitMQ (Mensageria)
```

## 🔧 **CONFIGURAÇÕES AVANÇADAS**

### **Variáveis de Ambiente (.env):**
```env
# Evolution API
EVOLUTION_PORT=8080
AUTHENTICATION_API_KEY=evolution_api_key_123456
CONFIG_SESSION_PHONE_CLIENT=Chrome
CONFIG_SESSION_PHONE_NAME=Evolution API
CONFIG_SESSION_PHONE_VERSION=2.3000.1014901307
```

### **Portas Expostas:**
- `8080`: Evolution API
- `5678`: n8n (para webhooks)
- `3000`: Grafana (monitoramento)

## 📊 **MONITORAMENTO**

O Grafana (`https://grafana.roladb.com.br`) pode ser usado para monitorar:
- Performance da Evolution API
- Logs de mensagens
- Métricas de uso

## 🔒 **SEGURANÇA**

- Todas as comunicações via HTTPS (Cloudflare Tunnel)
- API Key obrigatória para todas as requisições
- Dados persistidos em PostgreSQL criptografado
- Logs estruturados para auditoria

## 🆘 **TROUBLESHOOTING**

### **QR Code não aparece:**
1. Verificar se a instância foi criada
2. Confirmar API Key
3. Verificar logs: `docker-compose logs evolution-api`

### **Mensagens não chegam:**
1. Verificar webhook configurado
2. Confirmar n8n acessível
3. Verificar logs de ambos os serviços

### **Comandos Úteis:**
```bash
# Ver logs
docker-compose logs evolution-api -f

# Restart serviço
docker-compose restart evolution-api

# Status dos containers
docker-compose ps
```
