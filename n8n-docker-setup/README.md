
# n8n Starter Kit - Ecossistema Completo de Automação com WhatsApp

Este projeto fornece uma configuração completa do **n8n Starter Kit** usando Docker Compose, incluindo PostgreSQL, Redis, RabbitMQ, Grafana, Nginx, Evolution API e **Evolution Manager** para integração com WhatsApp. Ideal para automações robustas e fácil migração para produção na nuvem.

## 🚀 Características

- **n8n** - Plataforma de automação low-code
- **Evolution Manager + API** - Integração completa com WhatsApp Business API
- **PostgreSQL** - Banco de dados relacional robusto para dados estruturados
- **Redis** - Sistema de filas e cache para processamento assíncrono
- **RabbitMQ** - Message broker para comunicação entre serviços
- **Grafana** - Dashboards e visualização de dados em tempo real
- **Nginx** - Proxy reverso com SSL/TLS (opcional)
- **Backup automático** - Scripts para backup dos bancos de dados
- **Configuração flexível** - Fácil personalização via variáveis de ambiente
- **Pronto para produção** - Configurações de segurança e performance

## 📋 Pré-requisitos

- Docker Engine 20.10+
- Docker Compose 2.0+
- 4GB RAM mínimo (8GB recomendado)
- 10GB espaço em disco

## 🛠️ Instalação Rápida

### 1. Clone ou baixe este projeto



```bash
git clone <este-repositorio>
cd n8n-docker-setup
```

### 2. Configure as variáveis de ambiente

```bash
# Copie o arquivo de exemplo (se necessário)
cp .env.example .env

# Edite o arquivo .env com suas configurações
nano .env
```

**⚠️ IMPORTANTE:** Altere todas as senhas padrão no arquivo `.env` antes de usar em produção!

### 3. Inicie os serviços

```bash
# Desenvolvimento local (sem Nginx)
docker-compose up -d

# Ou para produção com Nginx
docker-compose --profile production up -d
```

### 4. Acesse as interfaces

- **n8n:** http://localhost:5678 (admin / admin_secure_password_2024)
- **Evolution Manager:** http://localhost:9615 (Interface de gerenciamento WhatsApp)
- **Evolution API:** http://localhost:8080 (API docs: /manager/docs)

### 5. Configuração rápida do Evolution Manager

```bash
# Usar script automatizado (Linux/Mac)
make evolution

# Ou no Windows PowerShell
.\scripts\evolution-setup.ps1

# Ou manualmente
docker-compose up -d evolution-api evolution-manager
```

## 📱 WhatsApp Integration (Evolution Manager)

Para usar a integração com WhatsApp:

1. **Acesse o Evolution Manager**: http://localhost:9615
2. **Crie uma instância** de WhatsApp
3. **Escaneie o QR Code** com seu WhatsApp
4. **Configure webhooks** no n8n para receber mensagens

Documentação completa: [EVOLUTION-MANAGER.md](./EVOLUTION-MANAGER.md)

## 📁 Estrutura do Projeto

```
n8n-docker-setup/
├── docker-compose.yml      # Configuração principal
├── .env                    # Variáveis de ambiente
├── .env.example           # Exemplo de configuração
├── init-data.sh           # Script de inicialização do PostgreSQL
├── README.md              # Esta documentação
├── EVOLUTION-MANAGER.md   # Documentação do Evolution Manager
├── local-files/           # Arquivos compartilhados com n8n
├── custom-nodes/          # Nós personalizados do n8n
├── backups/              # Backups dos bancos de dados
├── scripts/              # Scripts utilitários
│   ├── backup.sh         # Script de backup
│   ├── evolution-setup.sh # Setup do Evolution Manager (Linux/Mac)
│   └── evolution-setup.ps1# Setup do Evolution Manager (Windows)
├── redis/                # Configuração do Redis
│   └── redis.conf        # Configuração principal do Redis
├── mongo/                # Configuração do MongoDB
│   ├── mongod.conf       # Configuração principal do MongoDB
│   └── init-mongo.js     # Script de inicialização do MongoDB
└── nginx/                # Configuração do Nginx
    ├── nginx.conf        # Configuração principal (inclui Evolution routes)
    ├── ssl/              # Certificados SSL
    └── logs/             # Logs do Nginx
```

## ⚙️ Configuração Detalhada

### Variáveis de Ambiente Principais

| Variável | Descrição | Padrão |
|----------|-----------|---------|
| `POSTGRES_PASSWORD` | Senha do PostgreSQL | `n8n_secure_password_2024` |
| `REDIS_PASSWORD` | Senha do Redis | `redis_secure_password_2024` |
| `MONGO_ROOT_PASSWORD` | Senha do admin MongoDB | `mongo_secure_password_2024` |
| `MONGO_PASSWORD` | Senha do usuário n8n MongoDB | `n8n_mongo_password_2024` |
| `N8N_BASIC_AUTH_USER` | Usuário do n8n | `admin` |
| `N8N_BASIC_AUTH_PASSWORD` | Senha do n8n | `admin_secure_password_2024` |
| `N8N_HOST` | Host do n8n | `localhost` |
| `WEBHOOK_URL` | URL base para webhooks | `http://localhost:5678` |

### Portas dos Serviços

| Serviço | Porta | Descrição |
|---------|-------|-----------|
| n8n | 5678 | Interface web principal |
| PostgreSQL | 5432 | Banco de dados relacional |
| MongoDB | 27017 | Banco de dados NoSQL |
| Redis | 6379 | Cache e filas |
| RabbitMQ | 5672 | Message broker (AMQP) |
| RabbitMQ Management | 15672 | Interface web do RabbitMQ |
| Grafana | 3000 | Dashboards e visualização |
| Prometheus | 9090 | Coleta de métricas |
| Nginx | 80/443 | Proxy reverso (opcional) |

### Configuração para Produção

Para usar em produção, edite o arquivo `.env` e descomente as seções de produção:

```bash
# Configurações para Produção
DOMAIN_NAME=meu-n8n.exemplo.com
N8N_PROTOCOL=https
WEBHOOK_URL=https://n8n.meu-dominio.com
```

## 🔧 Comandos Úteis

### Usando Makefile (Recomendado)

```bash
# Ver todos os comandos disponíveis
make help

# Instalação e configuração inicial
make install

# Iniciar todos os serviços
make start

# Parar todos os serviços  
make stop

# Ver logs específicos
make logs-n8n
make logs-evolution-api
make logs-evolution-manager

# Evolution Manager
make evolution            # Setup completo do Evolution
make evolution-start      # Iniciar apenas Evolution services
make evolution-status     # Verificar status
make evolution-logs       # Ver logs do Evolution
```

### Gerenciamento dos Serviços

```bash
# Iniciar todos os serviços
docker-compose up -d

# Parar todos os serviços
docker-compose down

# Reiniciar um serviço específico
docker-compose restart n8n

# Ver logs de um serviço
docker-compose logs -f n8n

# Ver status dos serviços
docker-compose ps
```



### Gerenciamento dos Bancos de Dados

```bash
# Conectar ao PostgreSQL
docker-compose exec postgres psql -U n8n -d n8n

# Conectar ao MongoDB
docker-compose exec mongodb mongosh -u admin -p mongo_secure_password_2024

# Conectar ao Redis
docker-compose exec redis redis-cli -a redis_secure_password_2024

# Backup do PostgreSQL
docker-compose --profile backup up backup

# Backup manual do MongoDB
docker-compose exec mongodb mongodump --uri="mongodb://admin:mongo_secure_password_2024@localhost:27017/n8n_mongo" --out=/data/db/backup

# Restaurar backup do PostgreSQL
docker-compose exec postgres pg_restore -U n8n -d n8n /backups/backup_file.sql

# Ver logs dos bancos
docker-compose logs -f postgres
docker-compose logs -f mongodb
docker-compose logs -f redis
```

### Monitoramento e Manutenção

```bash
# Ver uso de recursos
docker stats

# Ver volumes criados
docker volume ls

# Limpar dados (CUIDADO!)
docker-compose down -v  # Remove todos os volumes

# Backup completo do sistema
tar -czf n8n-backup-$(date +%Y%m%d).tar.gz \
  --exclude='./backups' \
  --exclude='./nginx/logs' \
  .

# Verificar saúde dos serviços
docker-compose ps
```

## 🔒 Segurança

### Configurações Recomendadas para Produção

1. **Altere todas as senhas padrão**
2. **Configure SSL/TLS com certificados válidos**
3. **Use firewall para restringir acesso às portas**
4. **Configure backup automático**
5. **Monitore logs regularmente**

### Hardening dos Bancos de Dados

```bash
# PostgreSQL - Configurações adicionais de segurança
# Edite postgresql.conf para:
# - ssl = on
# - log_connections = on
# - log_disconnections = on

# MongoDB - Configurações adicionais de segurança
# Edite mongod.conf para:
# - security.authorization: enabled
# - net.ssl.mode: requireSSL

# Redis - Configurações adicionais de segurança
# Edite redis.conf para:
# - rename-command CONFIG ""
# - rename-command EVAL ""
```

## 🚀 Migração para Nuvem

### AWS (Amazon Web Services)

```bash
# 1. Configure AWS CLI
aws configure

# 2. Crie instância EC2
aws ec2 run-instances --image-id ami-0abcdef1234567890 --instance-type t3.medium

# 3. Configure RDS para PostgreSQL
aws rds create-db-instance --db-instance-identifier n8n-postgres

# 4. Configure ElastiCache para Redis
aws elasticache create-cache-cluster --cache-cluster-id n8n-redis

# 5. Configure DocumentDB para MongoDB
aws docdb create-db-cluster --db-cluster-identifier n8n-mongo
```

### Google Cloud Platform

```bash
# 1. Configure gcloud CLI
gcloud auth login

# 2. Crie instância Compute Engine
gcloud compute instances create n8n-instance --machine-type=e2-medium

# 3. Configure Cloud SQL para PostgreSQL
gcloud sql instances create n8n-postgres --database-version=POSTGRES_15

# 4. Configure Memorystore para Redis
gcloud redis instances create n8n-redis --size=1 --region=us-central1
```

### Azure

```bash
# 1. Configure Azure CLI
az login

# 2. Crie grupo de recursos
az group create --name n8n-rg --location eastus

# 3. Crie VM
az vm create --resource-group n8n-rg --name n8n-vm --image Ubuntu2204

# 4. Configure Azure Database for PostgreSQL
az postgres server create --resource-group n8n-rg --name n8n-postgres
```

## 📊 Monitoramento e Logs

### Configuração de Logs Centralizados

```yaml
# Adicione ao docker-compose.yml para logs centralizados
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

### Métricas e Alertas

```bash
# Instalar Prometheus e Grafana (opcional)
curl -L https://github.com/prometheus/prometheus/releases/download/v2.40.0/prometheus-2.40.0.linux-amd64.tar.gz | tar xz

# Configurar alertas por email
# Edite alertmanager.yml
```

## 🆘 Solução de Problemas

### Problemas Comuns

1. **Erro de conexão com banco de dados**
   ```bash
   # Verificar se os serviços estão rodando
   docker-compose ps
   
   # Verificar logs
   docker-compose logs postgres
   ```

2. **n8n não inicia**
   ```bash
   # Verificar logs do n8n
   docker-compose logs n8n
   
   # Verificar variáveis de ambiente
   docker-compose config
   ```

3. **Problemas de performance**
   ```bash
   # Verificar uso de recursos
   docker stats
   
   # Aumentar memória do Redis
   # Edite .env: REDIS_MAXMEMORY=1gb
   ```

### Comandos de Diagnóstico

```bash
# Testar conectividade entre serviços
docker-compose exec n8n ping postgres
docker-compose exec n8n ping mongodb
docker-compose exec n8n ping redis

# Verificar configuração
docker-compose config

# Verificar volumes
docker volume inspect n8n-docker-setup_postgres_data
```

## 📚 Recursos Adicionais

- [Documentação oficial do n8n](https://docs.n8n.io/)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [MongoDB Documentation](https://docs.mongodb.com/)
- [Redis Documentation](https://redis.io/documentation)

## 🤝 Contribuição

Para contribuir com este projeto:

1. Faça um fork do repositório
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo LICENSE para mais detalhes.

---

**Desenvolvido com ❤️ para a comunidade n8n brasileira**

