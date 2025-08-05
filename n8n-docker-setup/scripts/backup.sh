#!/bin/bash

# Script de Backup do n8n PostgreSQL
# Este script cria backups automáticos do banco de dados

set -e

# Configurações
BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="n8n_backup_${DATE}.sql"
POSTGRES_HOST="postgres"
POSTGRES_PORT="5432"

# Criar diretório de backup se não existir
mkdir -p "$BACKUP_DIR"

echo "Iniciando backup do banco de dados n8n..."
echo "Data/Hora: $(date)"
echo "Arquivo: $BACKUP_FILE"

# Realizar backup
pg_dump -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" > "$BACKUP_DIR/$BACKUP_FILE"

# Comprimir backup
gzip "$BACKUP_DIR/$BACKUP_FILE"

echo "Backup concluído: $BACKUP_DIR/${BACKUP_FILE}.gz"

# Limpar backups antigos (manter apenas os últimos 7 dias)
find "$BACKUP_DIR" -name "n8n_backup_*.sql.gz" -mtime +7 -delete

echo "Limpeza de backups antigos concluída."
echo "Backup finalizado com sucesso!"

# Listar backups disponíveis
echo ""
echo "Backups disponíveis:"
ls -la "$BACKUP_DIR"/n8n_backup_*.sql.gz 2>/dev/null || echo "Nenhum backup encontrado."

